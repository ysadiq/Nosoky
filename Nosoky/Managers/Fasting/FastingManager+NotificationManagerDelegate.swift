//
//  FastingManager+NotificationManagerDelegate.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/7/21.
//

import Foundation

extension FastingManager: NotificationManagerDataSource {
    func notificationContents(for notificationManager: NotificationManager, at day: Int) -> [NotificationContent] {
        var notificationContents: [NotificationContent] = []

        whiteDaysDates.first {
            $0.gregorian == "today"
        }
    }
}
