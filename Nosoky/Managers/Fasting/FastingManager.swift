//
//  FastingManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

class FastingManager {
    // MARK: - Initializer
    public static let shared = FastingManager()
    init(notificationManager: NotificationManager = NotificationManager()) {
        self.notificationManager = notificationManager
        self.notificationManager.delegate = self
    }

    // MARK: - Private properties
    private let notificationManager: NotificationManager

    // MARK: - Public properties
    var dates: [DateClass] = [] {
        didSet {
            notificationManager.addNotificationsIfNeeded()
        }
    }

    var whiteDaysDates: [DateClass] {
        dates.filter { $0.gregorian >= "today" && $0.isWhiteDay }
    }
    var whiteDaysNotifications: [NotificationContent] {
        var notificationContents: [NotificationContent] = []
        whiteDaysDates.forEach {
            guard let dateString = DateHelper.date(from: $0.gregorian) else {
                return
            }
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateString)
            dateComponents.hour = 12
            dateComponents.minute = 0
            guard let day = dateComponents.day, let month = dateComponents.month else {
                return
            }

            notificationContents.append(
                NotificationContent(
                    id: "WDF\(day)\(month)",
                    title: "White Days Fasting",
                    subtitle: "",
                    body: "",
                    dateComponents: dateComponents
                )
            )
        }
        return notificationContents
    }

    var weeklyDates: [DateClass] {
        dates.filter { $0.isMonday || $0.isThursday }
    }
    var weeklyNotifications: [NotificationContent] {
        var notificationContents: [NotificationContent] = []
        weeklyDates.forEach {
            guard let dateString = DateHelper.date(from: $0.gregorian) else {
                return
            }

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateString)
            dateComponents.hour = 12
            dateComponents.minute = 0
            guard let day = dateComponents.day, let month = dateComponents.month else {
                return
            }

            let notification = NotificationContent(
                id: "MTF\(day)\(month)",
                title: ($0.isMonday ? "Monday" : "Thursday") + " " + "Fasting",
                subtitle: "",
                body: "",
                dateComponents: dateComponents
            )
            notificationContents.append(notification)
        }
        return notificationContents
    }
    
    var shawwalDates: [DateClass] {
        dates.filter { $0.isFirstSixDaysOfShawal }
    }
    var shawwalNotifications: [NotificationContent] {
        var notificationContents: [NotificationContent] = []
        shawwalDates.forEach {
            guard let dateString = DateHelper.date(from: $0.gregorian) else {
                return
            }

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateString)
            dateComponents.hour = 12
            dateComponents.minute = 0
            guard let day = dateComponents.day, let month = dateComponents.month else {
                return
            }

            let notification = NotificationContent(
                id: "SDF\(day)\(month)",
                title: "Shawwal Fasting",
                subtitle: "",
                body: "",
                dateComponents: dateComponents
            )
            notificationContents.append(notification)
        }
        return notificationContents
    }

    var ashuraDates: [DateClass] {
        dates.filter { $0.isAshura }
    }
    var arafaDate: DateClass {
        dates.filter { $0.isArafa }[0]
    }
    var hijDates: [DateClass] {
        dates.filter { $0.isFirstNineDaysOfHij }
    }
    /*
    // MARK: - Private methods
    private func setWeeklyFastingDays() {
        weeklyDates = dates.filter { date in
            let hijriDateStrings = date.hijri.split(separator: "-")
            let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateStrings[0]), month: Int(hijriDateStrings[1]), day: Int(hijriDateStrings[2]))
            let day = DateHelper.string(from: hijriDateComponents.date!, dateFormat: "EEEE", calendar: .islamic)

            return ["Monday", "Thursday"].contains(day)
        }


    }

    private func setWhiteDaysFastingDays() {
        whiteDaysDates = dates.filter { date in
            let hijriDateStrings = date.hijri.split(separator: "-")
            let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateStrings[0]), month: Int(hijriDateStrings[1]), day: Int(hijriDateStrings[2]))

            return [13, 14, 15].contains(hijriDateComponents.day)
        }
    }

    private func setYearlyFastingDays() {
        shawwalDates = dates.filter { date in
            let hijriDateStrings = date.hijri.split(separator: "-")
            let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateStrings[0]), month: Int(hijriDateStrings[1]), day: Int(hijriDateStrings[2]))

            return (2...7) ~= hijriDateComponents.day! && hijriDateComponents.month == 8
        }

        ashuraDates = dates.filter { date in
            let hijriDateStrings = date.hijri.split(separator: "-")
            let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateStrings[0]), month: Int(hijriDateStrings[1]), day: Int(hijriDateStrings[2]))

            return [9, 10].contains(hijriDateComponents.day) && hijriDateComponents.month == 1
        }

        arafaDate = dates.first { date in
            let hijriDateStrings = date.hijri.split(separator: "-")
            let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateStrings[0]), month: Int(hijriDateStrings[1]), day: Int(hijriDateStrings[2]))

            return hijriDateComponents.day == 9 && hijriDateComponents.month == 12
        }

        hijDates = dates.filter { date in
            let hijriDateStrings = date.hijri.split(separator: "-")
            let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateStrings[0]), month: Int(hijriDateStrings[1]), day: Int(hijriDateStrings[2]))

            return (1...9) ~= hijriDateComponents.day! && hijriDateComponents.month == 12
        }
    }*/
}
