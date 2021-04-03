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
    }

    override func tearDown() {
        notificationManager = nil

        super.tearDown()
    }

    func testAddNotificationsIfNeeded() {
        var datetimes: [Datetime] = []
        let expectation = XCTestExpectation(description: "fetch prayer times")
        notificationCenter.grantAuthorization = true
        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)

        // Test that no notification is added when maximum is reached
        notificationManager.addNotificationExpectation = XCTestExpectation(description: "Maximum number of notifications")
        notificationManager.addNotificationExpectation.isInverted = true
        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
    }

        notificationCenter.grantAuthorization = true

        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)
    }
}

class NotificationManagerMock: NotificationManager {
    var addNotificationExpectation = XCTestExpectation(description: "addNotification(for prayer:, at date:)")
    var numberOfAddedNotifications: Int = 0

    override func addNotification(for prayer: Prayer, at date: DateComponents) {
        super.addNotification(for: prayer, at: date)

        numberOfAddedNotifications += 1

        addNotificationExpectation.fulfill()
    }
}
