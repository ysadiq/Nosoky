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

    func testNotificationContent() {
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

        // 64 notifications is equal to 10 days prayers [6(prayers) * 10(days) = 60] + 4 prayers
        // Asr prayer of 11th/04/2021 is the expected last added notification
        XCTAssertEqual(notificationManager.lastAddedNotificationPrayer?.name, "Asr")
        XCTAssertEqual(notificationManager.lastAddedNotificationPrayer?.time.hour, 15)
        XCTAssertEqual(notificationManager.lastAddedNotificationPrayer?.time.minute, 30)
        XCTAssertEqual(notificationManager.lastAddedNotificationDate?.day, 11)
        XCTAssertEqual(notificationManager.lastAddedNotificationDate?.month, 4)
        XCTAssertEqual(notificationManager.lastAddedNotificationDate?.year, 2021)
    }
}

class NotificationManagerMock: NotificationManager {
    var addNotificationExpectation = XCTestExpectation(description: "addNotification(for prayer:, at date:)")
    var lastAddedNotificationDate: DateComponents?
    var lastAddedNotificationPrayer: Prayer?
    var numberOfAddedNotifications: Int = 0

    override func addNotification(for prayer: Prayer, at date: DateComponents) {
        super.addNotification(for: prayer, at: date)

        lastAddedNotificationDate = date
        lastAddedNotificationPrayer = prayer
        numberOfAddedNotifications += 1

        addNotificationExpectation.fulfill()
    }
}
