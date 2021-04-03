//
//  UserNotificationCenterMock.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 4/3/21.
//

import NotificationCenter

class UserNotificationCenterMock: UserNotificationCenter {
    var requests: [UNNotificationRequest] = []
    let maximumNumberOfNotification = 64
    var grantAuthorization = false
    var error: Error?


    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(grantAuthorization, error)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        requests.append(request)
        completionHandler?(nil)
    }

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(requests)
    }
}
