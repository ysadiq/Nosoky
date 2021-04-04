//
//  NotificationManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import Foundation
import NotificationCenter

typealias NotificationContent = (title: String, subtitle: String?, adhan: AdhanFileName?)

enum AdhanFileName: String {
    case mini = "Adhan-makkah.m4a"
    case fajr = "Adhan-fajr.m4a"
}

class NotificationManager {
    // MARK: - Private properties
    let maximumNumberOfNotification = 64
    let userNotificationCenter: UserNotificationCenter
    var addNotificationFromDate = Date()

    // MARK: - Initializer
    init(userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()) {
        self.userNotificationCenter = userNotificationCenter
    }

    // MARK: - Public methods
    func addNotificationsIfNeeded(for monthPrayers: [Datetime]) {
        shouldAddNotifications { status, numberOfPendingNotifications in
            guard status,
                  var numberOfPendingNotifications = numberOfPendingNotifications else {
                return
            }

            let currentDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: self.addNotificationFromDate
            )

            let monthPrayers = monthPrayers.filter { dayPrayersAndDate in
                guard let prayersDay = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: DateHelper.date(from: dayPrayersAndDate.date.gregorian)
                ).day else { return false }

                guard let today = currentDate.day else { return false }

                return prayersDay >= today
            }

            for dayPrayers in monthPrayers {
                let prayerDate = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: DateHelper.date(from: dayPrayers.date.gregorian)
                )

                let dayPrayers = PrayerManager.shared.prayersList(of: dayPrayers.times)
                for prayer in dayPrayers {
                    guard numberOfPendingNotifications < self.maximumNumberOfNotification else {
                        break
                    }

                    if prayerDate.day == currentDate.day && (currentDate.hour! > prayer.time.hour! || (currentDate.hour! == prayer.time.hour! && currentDate.minute! > prayer.time.minute!)) {
                        continue
                    }

                    self.addNotification(for: prayer, at: prayerDate)
                    numberOfPendingNotifications += 1
                }
            }
        }
    }

    // MARK: - Internal Methods
    func shouldAddNotifications(_ completion: @escaping (_ status: Bool, _ numberOfPendingNotifications: Int?) -> Void) {
        userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { [weak self] authorizationStatus, _ in
            guard let self = self,
                  authorizationStatus else {
                completion(false, nil)
                return
            }

            self.userNotificationCenter.getPendingNotificationRequests { pendingNotifications in
                completion(pendingNotifications.count < self.maximumNumberOfNotification, pendingNotifications.count)
            }
        }
    }

    func addNotification(for prayer: Prayer, at date: DateComponents) {
        guard let notificationContent = notificationContent(for: prayer) else {
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
        content.title = notificationContent.title
        if let adhan = notificationContent.adhan?.rawValue {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: adhan))
        }
        if let subtitle = notificationContent.subtitle {
            content.subtitle = subtitle
        }

        let randomIdentifier = prayer.id
        let request = UNNotificationRequest(identifier: randomIdentifier, content: content, trigger: trigger)

        userNotificationCenter.add(request) { error in
            if error == nil {
                print("\(prayer) at date \(date) notification did add for \(randomIdentifier)")

            } else {
                print("\(prayer) at date \(date) notification did fail with error \(error!)")
            }
        }
    }

    func notificationContent(for prayer: Prayer) -> NotificationContent? {
        switch prayer.name {
        case "Dhuhr": return (title: "الظُهْر", subtitle: nil, adhan: .mini)
        case "Asr": return (title: "العَصْر", subtitle: nil, adhan: .mini)
        case "Maghrib": return (title: "المَغْرِبْ", subtitle: nil, adhan: .mini)
        case "Isha": return (title: "العِشَاء", subtitle: nil, adhan: .mini)
        case "Sunrise":return (title: "الضُحَىٰ", subtitle: nil, adhan: .mini)
        case "Night":
            return (
                title: "الثلث الأخير من اليل",
                subtitle: "إِنَّ نَاشِئَةَ ٱلَّيْلِ هِىَ أَشَدُّ وَطْـًٔا وَأَقْوَمُ قِيلًا",
                adhan: .mini
            )
        case "Fajr":
            return (
                title: "الفجر",
                subtitle: "الصلاة خير من النوم",
                adhan: .fajr
            )
        case "Jumuah":
            return (
                title: "الجُمْعَة",
                subtitle: "یَـٰۤأَیُّهَا ٱلَّذِینَ ءَامَنُوۤا۟ إِذَا نُودِیَ لِلصَّلَوٰةِ مِن یَوۡمِ ٱلۡجُمُعَةِ فَٱسۡعَوۡا۟ إِلَىٰ ذِكۡرِ ٱللَّهِ",
                adhan: .mini
            )
        default:
            return nil
        }
    }
}
