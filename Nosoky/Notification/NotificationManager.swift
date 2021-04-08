//
//  NotificationManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import Foundation
import NotificationCenter

enum Sound: String {
    case miniAdhan = "Adhan-makkah.m4a"
    case fajrAdhan = "Adhan-fajr.m4a"
}

protocol NotificationManagerDataSource: class {
    func notificationContents(for notificationManager: NotificationManager, at day: Int) -> [NotificationContent]
}

class NotificationManager {
    // MARK: - Public properties
    weak var delegate: NotificationManagerDataSource?

    // MARK: - Private properties
    let maximumNumberOfNotification = 64
    let userNotificationCenter: UserNotificationCenter
    var addNotificationFromDate = Date()

    // MARK: - Initializer
    init(userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()) {
        self.userNotificationCenter = userNotificationCenter
    }

    // MARK: - Public methods
    func addNotificationsIfNeeded() {
        shouldAddNotifications { [weak self] status, pendingNotifications in
            guard let self = self,
                  let delegate = self.delegate,
                  status else {
                return
            }

            var numberOfPendingNotifications = pendingNotifications.count
            let currentDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: self.addNotificationFromDate
            )

            guard let day = currentDate.day else { return }

            for day in day...31
            where numberOfPendingNotifications < self.maximumNumberOfNotification {
                let notificationContents = delegate.notificationContents(for: self, at: day)
                for notification in notificationContents where
                    numberOfPendingNotifications < self.maximumNumberOfNotification &&
                    !self.isDuplicate(notification, pendingNotifications) &&
                    !self.isPast(notification) {

                    self.addNotification(notification)
                    numberOfPendingNotifications += 1
                }
            }
        }
    }

    // MARK: - Internal Methods
    func shouldAddNotifications(_ completion: @escaping (_ status: Bool, _ pendingNotifications: [UNNotificationRequest]) -> Void) {
        userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { [weak self] authorizationStatus, _ in
            guard let self = self,
                  authorizationStatus else {
                completion(false, [])
                return
            }

            self.userNotificationCenter.getPendingNotificationRequests { pendingNotifications in
                completion(pendingNotifications.count < self.maximumNumberOfNotification, pendingNotifications)
            }
        }
    }

    func isPast(_ notification: NotificationContent) -> Bool {
        let currentDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: self.addNotificationFromDate
        )

        guard let notificationHour = notification.dateComponents.hour,
              let notificationMinute = notification.dateComponents.minute,
              let currentHour = currentDate.hour,
              let currentMinute = currentDate.minute else {
            print("Error: notification hour or minute is missing")
            return true
        }

        return notification.dateComponents.day == currentDate.day &&
            (currentHour > notificationHour ||
            (currentHour == notificationHour && currentMinute > notificationMinute))
    }

    func isDuplicate(_ notification: NotificationContent, _ pendingNotifications: [UNNotificationRequest]) -> Bool {
        pendingNotifications.first { $0.identifier == notification.id } != nil
    }

    func addNotification(_ notificationContent: NotificationContent?) {
        guard let notificationContent = notificationContent else {
            return
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationContent.dateComponents, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = notificationContent.title
        if let sound = notificationContent.sound?.rawValue {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
        }
        if let subtitle = notificationContent.subtitle {
            content.subtitle = subtitle
        }
        if let body = notificationContent.body {
            content.body = body
        }


        let request = UNNotificationRequest(identifier: "\(notificationContent.id)", content: content, trigger: trigger)

        userNotificationCenter.add(request) { error in
            if error == nil {
                print("\(notificationContent.title) at date \(notificationContent.dateComponents) notification did add for \(notificationContent.id)")

            } else {
                print("\(notificationContent.title) at date \(notificationContent.dateComponents) notification did fail with error \(error!)")
            }
        }
    }
}
