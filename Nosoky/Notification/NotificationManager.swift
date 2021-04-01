//
//  NotificationManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import Foundation
import NotificationCenter

class NotificationManager {
    // MARK: - Private properties
    private var numberOfAddedNotification = 0

    // MARK: - Initializer
    public static let shared = NotificationManager()
    private init() {}

    // MARK: - Private Methods
    private func shouldAddNotifications(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { authorizationStatus, _ in
            guard authorizationStatus else {
                completion(false)
                return
            }

            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                let maximumNumberOfNotification = 60
                completion(notifications.count < maximumNumberOfNotification)
            }
        }
    }

    // MARK: - Methods
    func addNotificationsIfNeeded(for monthPrayers: [Datetime]) {
        let maximumNumberOfNotification = 64
        var numberOfPendingNotifications = 0

        shouldAddNotifications { status in
            guard status else {
                return
            }

            let monthPrayers = monthPrayers.filter { dayPrayersAndDate in
                guard let prayersDay = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: DateHelper.date(from: dayPrayersAndDate.date.gregorian)
                ).day else { return false }

                guard let today = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: Date()
                ).day else { return false }

                return prayersDay >= today
            }

            for dayPrayers in monthPrayers {
                let prayerDate = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: DateHelper.date(from: dayPrayers.date.gregorian)
                )

                let dayPrayers = PrayerManager.shared.prayersList(of: dayPrayers.times)
                for prayer in dayPrayers {
                    guard numberOfPendingNotifications < maximumNumberOfNotification else {
                        break
                    }
                    self.addNotification(for: prayer, at: prayerDate)
                    numberOfPendingNotifications += 1
                }
            }
        }
    }

    private func addNotification(for prayer: Prayer, at date: DateComponents) {
        var dateComponents = DateComponents()

        dateComponents.hour = prayer.time.hour
        dateComponents.minute = prayer.time.minute

        dateComponents.day = date.day
        dateComponents.month = date.month
        dateComponents.year = date.year
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "\(prayer.name) prayer"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "miniAdhan.mp3"))

        let randomIdentifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: randomIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("\(prayer) at date \(date) notification did add")

            } else {
                print("\(prayer) at date \(date) notification did fail with error \(error!)")
            }
        }
    }
}
