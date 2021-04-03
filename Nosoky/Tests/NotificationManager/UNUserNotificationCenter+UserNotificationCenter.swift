//
//  UNUserNotificationCenter+UserNotificationCenter.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 4/3/21.
//

import NotificationCenter

protocol UserNotificationCenter {
    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void)
    func add(_ request: UNNotificationRequest,
             withCompletionHandler completionHandler: ((Error?) -> Void)?)

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

// Since our protocol requirements exactly match UNUserNotificationCenter's API,
// we can simply make it conform to it using an empty extension.
extension UNUserNotificationCenter: UserNotificationCenter {}
