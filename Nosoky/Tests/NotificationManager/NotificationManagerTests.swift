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
        notificationManager.delegate = self
        notificationManager.addNotificationFromDate = DateHelper.date(from: "2021-04-01")!
    }

    override func tearDown() {
        notificationManager = nil
        notificationCenter = nil

        super.tearDown()
    }

    func testAddNotificationsIfNeededWhenAuthorizationIsDisabled() {
        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = false
        notificationManager.addNotificationsIfNeeded()
        notificationManager.addNotificationExpectation.isInverted = true
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 0)
    }

    func testAddNotificationsIfNeeded() {
        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 64
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 64)

        // Test that no notification is added when maximum is reached
        notificationManager.addNotificationExpectation = XCTestExpectation(description: "Maximum number of notifications")
        notificationManager.addNotificationExpectation.isInverted = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
    }
}

extension NotificationManagerTests: NotificationManagerDataSource {
    func notificationContents(for notificationManager: NotificationManager) -> [NotificationContent]? {
        [
            NotificationContent(
                id: "",
                title: "",
                dateComponents: DateComponents(year: 2021, month: 10, day: 10, hour: 10, minute: 30)
            )
        ]
    }

    func notificationContents(for notificationManager: NotificationManager, at day: Int) -> [NotificationContent]? {
        nil
    }
}
