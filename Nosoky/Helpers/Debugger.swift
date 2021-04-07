//
//  Debugger.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/1/21.
//

import NotificationCenter

func printPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
        print(notifications.count)
        notifications.forEach {
            print($0.identifier)
            print($0.content.title)
            print($0.trigger!)
        }
    }
}
