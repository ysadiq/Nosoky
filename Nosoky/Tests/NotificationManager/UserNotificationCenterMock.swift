//
//  UserNotificationCenterMock.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 4/3/21.
//

import NotificationCenter

class UserNotificationCenterMock: UserNotificationCenter {
    var grantAuthorization = false
    var error: Error?

    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(grantAuthorization, error)
    }
}
