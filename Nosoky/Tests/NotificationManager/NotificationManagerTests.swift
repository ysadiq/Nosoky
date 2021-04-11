//
//  NotificationManagerTests.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 4/3/21.
//

import XCTest
import NotificationCenter

@testable import Nosoky

class NotificationManagerTests: XCTestCase {
    var notificationManager: NotificationManagerMock!
    var notificationCenter: UserNotificationCenterMock!

    override func setUp() {
        super.setUp()

        notificationCenter = UserNotificationCenterMock()
        notificationManager = NotificationManagerMock(userNotificationCenter: notificationCenter)
        notificationManager.delegate = PrayerManager.shared
        notificationManager.addNotificationFromDate = DateHelper.date(from: "2021-04-01")!
        PrayerManager.shared.todayAsString = "2021-04-01"
    }

    override func tearDown() {
        notificationManager = nil
        notificationCenter = nil

        super.tearDown()
    }

    func testAddNotificationsIfNeededWhenAuthorizationIsDisabled() {
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes { result, _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = false
        notificationManager.addNotificationsIfNeeded()
        notificationManager.addNotificationExpectation.isInverted = true
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 0)
    }

    func testAddNotificationsIfNeeded() {
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes { result, _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 5)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)

        // Test that no notification is added when maximum is reached
        notificationManager.addNotificationExpectation = XCTestExpectation(description: "Maximum number of notifications")
        notificationManager.addNotificationExpectation.isInverted = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
    }

    func testFridayNotification() {
        PrayerManager.shared.todayAsString = "2021-04-09"
        notificationManager.addNotificationFromDate = DateHelper.date(from: "2021-04-09")!

        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes { result, _ in
            PrayerManager.shared.prayerDateTimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)

        XCTAssertEqual(notificationCenter.requests.count, 64)
        XCTAssertEqual(notificationCenter.requests[3].content.title, "الجُمْعَة")
        XCTAssertEqual(notificationCenter.requests[3].content.body, "یَـٰۤأَیُّهَا ٱلَّذِینَ ءَامَنُوۤا۟ إِذَا نُودِیَ لِلصَّلَوٰةِ مِن یَوۡمِ ٱلۡجُمُعَةِ فَٱسۡعَوۡا۟ إِلَىٰ ذِكۡرِ ٱللَّهِ")
        let notificationDate = (notificationCenter.requests[3].trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 11)
        XCTAssertEqual(notificationDate?.minute, 56)
        XCTAssertEqual(notificationDate?.day, 9)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)
    }

    func testNextNotificationsAfterDeliveringNotifications() {
        // Fetch prayers
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes { result, _ in
            PrayerManager.shared.prayerDateTimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        // Add notifications
        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)

        // Test first notification
        XCTAssertEqual(notificationCenter.requests.first?.content.title, "الثلث الأخير من اليل")
        var notificationDate = (notificationCenter.requests.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 1)
        XCTAssertEqual(notificationDate?.minute, 0)
        XCTAssertEqual(notificationDate?.day, 1)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)

        // Deliver first notification
        notificationCenter.requests.removeFirst()
        XCTAssertEqual(notificationCenter.requests.count, 63)

        // Add new notification if there's available spot for notifications
        notificationManager.addNotificationExpectation = XCTestExpectation(description: #function)
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        // Test second notification
        XCTAssertEqual(notificationCenter.requests.count, 64)
        XCTAssertEqual(notificationCenter.requests.first?.content.title, "الفجر")
        notificationDate = (notificationCenter.requests.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 4)
        XCTAssertEqual(notificationDate?.minute, 23)
        XCTAssertEqual(notificationDate?.day, 1)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)

        // Deliver first notification
        notificationCenter.requests.removeFirst()
        XCTAssertEqual(notificationCenter.requests.count, 63)

        // Add new notification if there's available spot for notifications
        notificationManager.addNotificationExpectation = XCTestExpectation(description: #function)
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        // Test second notification
        XCTAssertEqual(notificationCenter.requests.count, 64)
        XCTAssertEqual(notificationCenter.requests.first?.content.title, "الضُحَىٰ")
        notificationDate = (notificationCenter.requests.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 5)
        XCTAssertEqual(notificationDate?.minute, 43)
        XCTAssertEqual(notificationDate?.day, 1)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)

        // Add new notification if there's available spot for notifications
        notificationManager.addNotificationExpectation = XCTestExpectation(description: #function)
        notificationManager.addNotificationExpectation.isInverted = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        // No available spot to add more notification
        XCTAssertEqual(notificationCenter.requests.count, 64)
    }

    func testAddNotificationsIfNeededForLastFiveDaysOfTheMonth() {
        let expectation = XCTestExpectation(description: "fetch prayer times")
        notificationManager.addNotificationFromDate = DateHelper.date(from: "2021-04-26")!
        DataProviderMock().prayerTimes { result, _ in
            PrayerManager.shared.prayerDateTimes = Array(result!.datetime.dropFirst(25))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 5
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 35)
    }

    func testLastAddedNotificationContent() {
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes { _, _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 1
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        // 64 notifications is equal 64 prayers
        // 10 days prayers + 4 prayers from day 11th
        // [10(days) * 6(prayers) = 60]
        // Night prayer of 10th/04/2021 is the expected last added notification
        XCTAssertEqual(notificationManager.lastAddedNotification?.title, "الثلث الأخير من اليل")
        XCTAssertEqual(notificationManager.lastAddedNotification?.dateComponents.hour, 0)
        XCTAssertEqual(notificationManager.lastAddedNotification?.dateComponents.minute, 54)
        XCTAssertEqual(notificationManager.lastAddedNotification?.dateComponents.day, 10)
        XCTAssertEqual(notificationManager.lastAddedNotification?.dateComponents.month, 4)
        XCTAssertEqual(notificationManager.lastAddedNotification?.dateComponents.year, 2021)

        XCTAssertEqual(notificationCenter.requests.last?.content.title, "الثلث الأخير من اليل")
        let notificationDate = (notificationCenter.requests.last?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 0)
        XCTAssertEqual(notificationDate?.minute, 54)
        XCTAssertEqual(notificationDate?.day, 10)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)
    }

    func testFirstAddedNotificationContent() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        PrayerManager.shared.prayerDateTimes = datetimes

        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 1
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        XCTAssertEqual(notificationManager.firstAddedNotification?.title, "الثلث الأخير من اليل")
        XCTAssertEqual(notificationManager.firstAddedNotification?.dateComponents.hour, 1)
        XCTAssertEqual(notificationManager.firstAddedNotification?.dateComponents.minute, 0)
        XCTAssertEqual(notificationManager.firstAddedNotification?.dateComponents.day, 1)
        XCTAssertEqual(notificationManager.firstAddedNotification?.dateComponents.month, 4)
        XCTAssertEqual(notificationManager.firstAddedNotification?.dateComponents.year, 2021)

        XCTAssertEqual(notificationCenter.requests.first?.content.title, "الثلث الأخير من اليل")
        XCTAssertEqual(notificationCenter.requests.first?.content.subtitle, "إِنَّ نَاشِئَةَ ٱلَّيْلِ هِىَ أَشَدُّ وَطْـًٔا وَأَقْوَمُ قِيلًا")
        let notificationDate = (notificationCenter.requests.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 1)
        XCTAssertEqual(notificationDate?.minute, 0)
        XCTAssertEqual(notificationDate?.day, 1)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)
    }
}

class NotificationManagerMock: NotificationManager {
    var addNotificationExpectation = XCTestExpectation(description: #function)

    var firstAddedNotification: NotificationContent?
    var lastAddedNotification: NotificationContent?

    var numberOfAddedNotifications: Int = 0

    override func addNotification(_ notificationContent: NotificationContent?) {
        super.addNotification(notificationContent)

        if firstAddedNotification == nil {
            firstAddedNotification = notificationContent
        } else {
            lastAddedNotification = notificationContent
        }
        numberOfAddedNotifications += 1

        addNotificationExpectation.fulfill()
    }
}
