//
//  NotificationManagerMock.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/8/21.
//

import XCTest
@testable import Nosoky

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
