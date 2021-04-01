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
        guard let notificationDetails = notificationContent(for: prayer) else {
            return
        }

        var dateComponents = DateComponents()
        dateComponents.hour = prayer.time.hour
        dateComponents.minute = prayer.time.minute
        dateComponents.day = date.day
        dateComponents.month = date.month
        dateComponents.year = date.year
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = notificationDetails.title
        if let adhan = notificationDetails.adhan?.rawValue {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: adhan))
        }
        if let subtitle = notificationDetails.subtitle {
            content.subtitle = subtitle
        }

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

    private func notificationContent(for prayer: Prayer) -> (title: String, subtitle: String?, adhan: AdhanFileName?)? {
        switch prayer.name {
        case "Fajr":
            return (
                title: "الفجر",
                subtitle: "الصلاة خير من النوم",
                adhan: .fajr
            )
        case "Dhuhur":
            return (
                title: "الظهر",
                subtitle: nil,
                adhan: .mini
            )
        case "Asr":
            return (
                title: "العصر",
                subtitle: nil,
                adhan: .mini
            )
        case "Maghrib":
            return (
                title: "المغرب",
                subtitle: nil,
                adhan: .mini
            )
        case "Isha":
            return (
                title: "العشاء",
                subtitle: nil,
                adhan: .mini
            )
        case "Night":
            return (
                title: "الثلث الأخير من اليل",
                subtitle: "إِنَّ نَاشِئَةَ ٱلَّيْلِ هِىَ أَشَدُّ وَطْـًٔا وَأَقْوَمُ قِيلًا",
                adhan: .mini
            )
        case "Sunrise":
            return (
                title: "الضحى",
                subtitle: nil,
                adhan: .mini
            )
        default:
            return nil
        }
    }

    enum AdhanFileName: String {
        case mini = "Adhan-makkah.m4a"
        case fajr = "Adhan-fajr.m4a"
    }
}
}
