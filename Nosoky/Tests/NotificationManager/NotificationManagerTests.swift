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
        let expectation = XCTestExpectation(description: "fetch prayer times")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationCenter.grantAuthorization = true
        var datetimes: [Datetime] = []

        DataProviderMock().prayerTimes(for: nil) { result, _ in
            datetimes = result!.datetime
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 58

        notificationManager.addNotificationsIfNeeded(for: datetimes)
        wait(for: [notificationManager.addNotificationExpectation], timeout: 5)
    }
}

class NotificationManagerMock: NotificationManager {
    var addNotificationExpectation = XCTestExpectation(description: "addNotification(for prayer:, at date:)")

    override func addNotification(for prayer: Prayer, at date: DateComponents) {
        super.addNotification(for: prayer, at: date)

        addNotificationExpectation.fulfill()
    }
}
