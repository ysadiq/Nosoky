//
//  PrayerManager+NotificationManagerDelegate.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/7/21.
//

import Foundation

extension PrayerManager: NotificationManagerDataSource {
    func notificationContents(for notificationManager: NotificationManager, at day: Int) -> [NotificationContent] {
        var notificationContents: [NotificationContent] = []

        let _dayPrayers = prayerDateTimes.first { dayPrayersAndDate in
            guard let prayersDate = DateHelper.date(from: dayPrayersAndDate.date.gregorian),
                  let prayersDay = Calendar.current.dateComponents([.day], from: prayersDate).day else {
                return false
            }

            return prayersDay >= day
        }

        guard let dayPrayers = _dayPrayers,
              let prayersDate = DateHelper.date(from: dayPrayers.date.gregorian) else {
            return []
        }

        var prayersDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: prayersDate
        )

        func prayerId(_ prayer: Prayer) -> String {
            "\(prayer.name)\(prayersDateComponents.year!)\(prayersDateComponents.month!)\(prayersDateComponents.day!)"
        }

        if let night = dayPrayers.times.night {
            prayersDateComponents.hour = night.time.hour
            prayersDateComponents.minute = night.time.minute

            notificationContents.append(
                NotificationContent(
                    id: prayerId(night),
                    title: "الثلث الأخير من اليل",
                    subtitle: "إِنَّ نَاشِئَةَ ٱلَّيْلِ هِىَ أَشَدُّ وَطْـًٔا وَأَقْوَمُ قِيلًا",
                    sound: .miniAdhan,
                    dateComponents: prayersDateComponents
                )
            )
        }

        if let fajr = dayPrayers.times.fajr {
            prayersDateComponents.hour = fajr.time.hour
            prayersDateComponents.minute = fajr.time.minute

            notificationContents.append(
                NotificationContent(
                    id: prayerId(fajr),
                    title: "الفجر",
                    subtitle: "الصلاة خير من النوم",
                    sound: .miniAdhan,
                    dateComponents: prayersDateComponents
                )
            )
        }

        if let sunrise = dayPrayers.times.sunrise {
            prayersDateComponents.hour = sunrise.time.hour
            prayersDateComponents.minute = sunrise.time.minute

            notificationContents.append(
                NotificationContent(
                    id: prayerId(sunrise),
                    title: "الضُحَىٰ",
                    sound: .miniAdhan,
                    dateComponents: prayersDateComponents
                )
            )
        }

        if let dhuhr = dayPrayers.times.dhuhr {
            prayersDateComponents.hour = dhuhr.time.hour
            prayersDateComponents.minute = dhuhr.time.minute

            var notification = NotificationContent(
                id: prayerId(dhuhr),
                title: "الظُهْر",
                sound: .miniAdhan,
                dateComponents: prayersDateComponents
            )

            if DateHelper.string(from: prayersDate, dateFormat: "EEEE") == "Friday" {
                notification.title = "الجُمْعَة"
                notification.body = "یَـٰۤأَیُّهَا ٱلَّذِینَ ءَامَنُوۤا۟ إِذَا نُودِیَ لِلصَّلَوٰةِ مِن یَوۡمِ ٱلۡجُمُعَةِ فَٱسۡعَوۡا۟ إِلَىٰ ذِكۡرِ ٱللَّهِ"
            }

            notificationContents.append(notification)
        }

        if let asr = dayPrayers.times.asr {
            prayersDateComponents.hour = asr.time.hour
            prayersDateComponents.minute = asr.time.minute

            notificationContents.append(
                NotificationContent(
                    id: prayerId(asr),
                    title: "العَصْر",
                    sound: .miniAdhan,
                    dateComponents: prayersDateComponents
                )
            )
        }

        if let maghrib = dayPrayers.times.maghrib {
            prayersDateComponents.hour = maghrib.time.hour
            prayersDateComponents.minute = maghrib.time.minute

            notificationContents.append(
                NotificationContent(
                    id: prayerId(maghrib),
                    title: "المَغْرِبْ",
                    sound: .miniAdhan,
                    dateComponents: prayersDateComponents
                )
            )
        }

        if let isha = dayPrayers.times.isha {
            prayersDateComponents.hour = isha.time.hour
            prayersDateComponents.minute = isha.time.minute

            notificationContents.append(
                NotificationContent(
                    id: prayerId(isha),
                    title: "العِشَاء",
                    sound: .miniAdhan,
                    dateComponents: prayersDateComponents
                )
            )
        }

        return notificationContents
    }
}
