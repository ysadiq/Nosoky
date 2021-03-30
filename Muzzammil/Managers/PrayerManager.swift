//
//  PrayerManager.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

typealias Prayer = (name: String, time: String)
typealias Time = (hour: Int, minute: Int)

class PrayerManager {
    // MARK: - Initializer
    public static let shared = PrayerManager()
    private init() {}

    // MARK: - Properties
    var prayerDateTimes: [Datetime] = []
    var lastNightThird: String?

    var currentTime =  {
        DateHelper.string(dateFormat: "HH:mm")
    }()

    var nextPrayer: Prayer? {
        while let prayer = todaysPrayers?.first {
            if prayer.time > currentTime {
                return prayer
            } else {
                todaysPrayers?.removeFirst()
            }
        }

        return nil
    }

    var otherPrayers: [Prayer]? {
        todaysPrayers?.filter { $0.name != nextPrayer?.name }
    }

    private lazy var todaysPrayers: [Prayer]? = {
        guard let prayers = prayerDateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times else {
            return nil
        }

        setLastThirdTime(maghribTime: prayers.maghrib, fajrTime: prayers.fajr)

        return [
            Prayer("Fajr", prayers.fajr),
            Prayer("Dhuhur", prayers.dhuhr),
            Prayer("Asr", prayers.asr),
            Prayer("Maghrib", prayers.maghrib),
            Prayer("Isha", prayers.isha)
        ]
    }()

    var timeLeftToNextPrayer: Time {
        let nextPrayer = (
            hour: Int(self.nextPrayer?.time.split(separator: ":").first ?? "") ?? 0,
            minute: Int(self.nextPrayer?.time.split(separator: ":").last ?? "") ?? 0
        )
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())

        var hoursDifference = differenceInHours(nextPrayer.hour,
                                                currentTime.hour ?? 0)
        let minutesDifference = differenceInMinutes(nextPrayer.minute,
                                                    currentTime.minute ?? 0,
                                                    &hoursDifference)

        let timeLeft = (
            hour: hoursDifference,
            minute: minutesDifference
        )

        return timeLeft
    }

    // MARK: - Methods

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

        lastNightThird = "\(fajrTime.hour - lastThirdNightLong):00"
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
