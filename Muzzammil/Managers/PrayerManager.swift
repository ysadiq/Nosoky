//
//  PrayerManager.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

typealias Prayer = (name: String, time: Time)
typealias Time = (hour: Int, minute: Int)

class PrayerManager {
    // MARK: - Initializer
    public static let shared = PrayerManager()
    private init() {}

    // MARK: - Properties
    var prayerDateTimes: [Datetime] = []
    var lastNightThird: Time?

    var currentTime: Time {
        (
            Calendar.current.dateComponents([.hour], from: Date()).hour ?? 0,
            Calendar.current.dateComponents([.minute], from: Date()).minute ?? 0
        )
    }

    var nextPrayer: Prayer? {
        while let prayer = todaysPrayers.first {
            if prayer.time.hour > currentTime.hour ||
                (prayer.time.hour == currentTime.hour && prayer.time.minute > currentTime.minute) {
                return prayer
            } else {
                todaysPrayers.removeFirst()
            }
        }

        return nil
    }

    var otherPrayers: [Prayer] {
        if let nextPrayer = nextPrayer {
            var prayers = todaysPrayers.filter { $0.name != nextPrayer.name }
            if prayers.count > 4 {
                _ = prayers.popLast()
            }
            return prayers
        } else {
            return tomorrowsPrayers.filter { $0.name != "Isha" && $0.name != "Night" }
        }
    }

    private lazy var todaysPrayers: [Prayer] = {
        guard let prayers = prayerDateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times else {
            return []
        }

        setLastThirdTime(maghribTime: prayers.maghrib, fajrTime: prayers.fajr)
        return buildPrayersList(prayers)
    }()

    private lazy var tomorrowsPrayers: [Prayer] = {
        guard let prayers = prayerDateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string(from: Date().addingTimeInterval(TimeInterval(60*60*24)))
        }).first?.times else {
            return []
        }

        return buildPrayersList(prayers)
    }()

    // MARK: - Methods

    private func buildPrayersList(_ prayers: Times) -> [Prayer] {
        [
            Prayer(
                "Night",
                lastNightThird ?? Time(0, 0)
            ),
            Prayer(
                "Fajr",
                (Int(prayers.fajr.split(separator: ":").first ?? "") ?? 0,
                Int(prayers.fajr.split(separator: ":").last ?? "") ?? 0)
            ),
            Prayer(
                "Dhuhur",
                (Int(prayers.dhuhr.split(separator: ":").first ?? "") ?? 0,
                Int(prayers.dhuhr.split(separator: ":").last ?? "") ?? 0)
            ),
            Prayer(
                "Asr",
                (Int(prayers.asr.split(separator: ":").first ?? "") ?? 0,
                Int(prayers.asr.split(separator: ":").last ?? "") ?? 0)
            ),
            Prayer(
                "Maghrib",
                (Int(prayers.maghrib.split(separator: ":").first ?? "") ?? 0,
                Int(prayers.maghrib.split(separator: ":").last ?? "") ?? 0)
            ),
            Prayer(
                "Isha",
                (Int(prayers.isha.split(separator: ":").first ?? "") ?? 0,
                Int(prayers.isha.split(separator: ":").last ?? "") ?? 0)
            )
        ]
    }

    func timeLeftTo(_ time: Time) -> (time: Time, timeUnit: String) {
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())

        var hoursDifference = differenceInHours(time.hour,
                                                currentTime.hour ?? 0)
        let minutesDifference = differenceInMinutes(time.minute,
                                                    currentTime.minute ?? 0,
                                                    &hoursDifference)
        return ((hoursDifference, minutesDifference), hoursDifference > 0 ? "hr" : "min")
    }


    /*
     calculate how long is the night
        Maghrib time 18:27
        Fajr time 4:27

        minutes 27 - 27 = 0
        hours 4 - 18 = -14+24 = 10 (subtract 1 if its 24 instead of 10)
        The night is 10 hours

     calculate how long is the last third of the night
        10/3 = 3.33 decimal
        3.33*60 = 200 minutes

     when does the 3rd part of the night start?
        4.27 - 3.33 =
        4 - 3 = 1
        27 - 33 = -6
        since the result is negative, add 60 to the minute and subtract 1 from the hour
            -6 + 60 = 54
            1 - 1 = 0
        the last third of the night starts at 00:54
    */
    func  setLastThirdTime(maghribTime: String, fajrTime: String) {
        // calculate how long is the night
        let maghribTime = (
            hour: Int(maghribTime.split(separator: ":").first ?? "") ?? 0,
            minute: Int(maghribTime.split(separator: ":").last ?? "") ?? 0
        )

        let fajrTime = (
            hour: Int(fajrTime.split(separator: ":").first ?? "") ?? 0,
            minute: Int(fajrTime.split(separator: ":").last ?? "") ?? 0
        )

        var hoursDifference = differenceInHours(fajrTime.hour, maghribTime.hour)
        let minutesDifference = differenceInMinutes(fajrTime.minute, maghribTime.minute, &hoursDifference)

        let nightLong = (
            hour: hoursDifference,
            minute: minutesDifference
        )

        // calculate how long is the last third of the night
        let lastThirdNightLong = nightLong.hour / 3

        lastNightThird = Time(fajrTime.hour - lastThirdNightLong, minutesDifference)
    }

    func differenceInMinutes(_ minute: Int, _ otherMinute: Int, _ hoursDifference: inout Int) -> Int {
        var minutesDifference = minute - otherMinute
        if minutesDifference < 0 {
            minutesDifference += 60
            hoursDifference -= 1
        }

        return minutesDifference
    }

    func differenceInHours(_ hour: Int, _ otherHour: Int) -> Int {
        var hoursDifference = hour - otherHour
        if hoursDifference < 0 {
            hoursDifference += 24
            if hoursDifference == 24 {
                hoursDifference -= 1
            }
        }

        return hoursDifference
    }
}
