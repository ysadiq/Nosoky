//
//  NotificationManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import Foundation
import NotificationCenter

class NotificationManager {
    // MARK: - Initializer
    public static let shared = NotificationManager()
    private init() {}

    // MARK: - Methods
    func setMonthlyNotification(for prayers: [Datetime]) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] status, _ in
            guard status else {
                return
            }

            prayers.forEach { datetime in
                let date = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: DateHelper.date(from: datetime.date.gregorian)
                )

                PrayerManager.shared.prayersList(of: datetime.times).forEach { prayer in
                    self?.addNotification(for: prayer, at: date)
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
