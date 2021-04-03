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
        notificationManager.addNotificationFromDate = DateHelper.date(from: "2021-04-01")
    }

    override func tearDown() {
        notificationManager = nil
        notificationCenter = nil

        super.tearDown()
    }

    func testAddNotificationsIfNeededWhenAuthorizationIsDisabled() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = false
        notificationManager.addNotificationsIfNeeded(for: datetimes)
        notificationManager.addNotificationExpectation.isInverted = true
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 0)
    }

    func testAddNotificationsIfNeeded() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)

        // Test that no notification is added when maximum is reached
        notificationManager.addNotificationExpectation = XCTestExpectation(description: "Maximum number of notifications")
        notificationManager.addNotificationExpectation.isInverted = true
        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
    }

    func testAddNotificationsIfNeededForLastFiveDaysOfTheMonth() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = Array(result!.datetime.dropFirst(25))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 5
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 30)
    }

    func testLastAddedNotificationContent() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded(for: datetimes)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 1
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        // 64 notifications is equal 64 prayers
        // 10 days prayers + 4 prayers from day 11th
        // [10(days) * 6(prayers) = 60]
        // Asr prayer of 11th/04/2021 is the expected last added notification
        XCTAssertEqual(notificationManager.lastAddedNotificationPrayer?.name, "Asr")
        XCTAssertEqual(notificationManager.lastAddedNotificationPrayer?.time.hour, 15)
        XCTAssertEqual(notificationManager.lastAddedNotificationPrayer?.time.minute, 30)
        XCTAssertEqual(notificationManager.lastAddedNotificationDate?.day, 11)
        XCTAssertEqual(notificationManager.lastAddedNotificationDate?.month, 4)
        XCTAssertEqual(notificationManager.lastAddedNotificationDate?.year, 2021)

        XCTAssertEqual(notificationCenter.requests.last?.content.title, "العصر")
        let notificationDate = (notificationCenter.requests.last?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 15)
        XCTAssertEqual(notificationDate?.minute, 30)
        XCTAssertEqual(notificationDate?.day, 11)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)
    }

    func testFirstAddedNotificationContent() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded(for: datetimes)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 1
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)

        // 64 notifications is equal 64 prayers
        // 10 days prayers + 4 prayers from day 11th
        // [10(days) * 6(prayers) = 60]
        // Asr prayer of 11th/04/2021 is the expected last added notification
        XCTAssertEqual(notificationManager.firstAddedNotificationPrayer?.name, "Night")
        XCTAssertEqual(notificationManager.firstAddedNotificationPrayer?.time.hour, 1)
        XCTAssertEqual(notificationManager.firstAddedNotificationPrayer?.time.minute, 5)
        XCTAssertEqual(notificationManager.firstAddedNotificationDate?.day, 1)
        XCTAssertEqual(notificationManager.firstAddedNotificationDate?.month, 4)
        XCTAssertEqual(notificationManager.firstAddedNotificationDate?.year, 2021)

        XCTAssertEqual(notificationCenter.requests.first?.content.title, "الثلث الأخير من اليل")
        let notificationDate = (notificationCenter.requests.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 1)
        XCTAssertEqual(notificationDate?.minute, 5)
        XCTAssertEqual(notificationDate?.day, 1)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)
    }
}

class NotificationManagerMock: NotificationManager {
    var addNotificationExpectation = XCTestExpectation(description: #function)

    var firstAddedNotificationDate: DateComponents?
    var firstAddedNotificationPrayer: Prayer?
    var lastAddedNotificationDate: DateComponents?
    var lastAddedNotificationPrayer: Prayer?

    var numberOfAddedNotifications: Int = 0

    override func addNotification(for prayer: Prayer, at date: DateComponents) {
        super.addNotification(for: prayer, at: date)

        if firstAddedNotificationDate == nil {
            firstAddedNotificationDate = date
            firstAddedNotificationPrayer = prayer
        } else {
            lastAddedNotificationDate = date
            lastAddedNotificationPrayer = prayer
        }
        numberOfAddedNotifications += 1

        addNotificationExpectation.fulfill()
    }
}
