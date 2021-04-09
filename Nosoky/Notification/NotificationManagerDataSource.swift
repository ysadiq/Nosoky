//
//  NotificationManagerDataSource.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/9/21.
//

protocol NotificationManagerDataSource: class {
    func notificationContents(for notificationManager: NotificationManager, at day: Int) -> [NotificationContent]?
    func notificationContents(for notificationManager: NotificationManager) -> [NotificationContent]?
}

extension NotificationManagerDataSource {
    func notificationContents(for notificationManager: NotificationManager, at day: Int) -> [NotificationContent]? {
        nil
    }

    func notificationContents(for notificationManager: NotificationManager) -> [NotificationContent]? {
        nil
    }
}
