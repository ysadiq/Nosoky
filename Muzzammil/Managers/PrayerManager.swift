//
//  PrayerManager.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

class PrayerManager {
    public static let shared = PrayerManager()
    private init() {}

    var prayerDateTimes: [Datetime] = []
    private var nextPrayer: Prayer?
    var otherPrayers: [Prayer] = []
    var lastNightThird: Prayer?
    lazy var currentTime =  {
        DateHelper.string(dateFormat: "HH:mm")
    }()
    lazy var todaysPrayers: Times? = {
        prayerDateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times
    }()

    func getNextPrayer() -> Prayer? {
        guard let todaysPrayers = todaysPrayers else {
            return nil
        }

        guard nextPrayer == nil else {
            return nextPrayer
        }

        if todaysPrayers.fajr > currentTime {
            nextPrayer = ("Fajr", todaysPrayers.fajr, nil)
        }

        if todaysPrayers.sunrise > currentTime {
            let sunrise: Prayer = ("Sunrise", todaysPrayers.sunrise, nil)
            if nextPrayer == nil {
                nextPrayer = sunrise
            } else {
                otherPrayers.append(sunrise)
            }
        }

        if todaysPrayers.dhuhr > currentTime {
            let dhuhr: Prayer = ("Dhuhr", todaysPrayers.dhuhr, nil)
            if nextPrayer == nil {
                nextPrayer = dhuhr
            } else {
                otherPrayers.append(dhuhr)
            }
        }

        if todaysPrayers.asr > currentTime {
            let asr: Prayer = ("Asr", todaysPrayers.asr, nil)
            if nextPrayer == nil {
                nextPrayer = asr
            } else {
                otherPrayers.append(asr)
            }
        }

        if todaysPrayers.maghrib > currentTime {
            let maghrib: Prayer = ("Maghrib", todaysPrayers.maghrib, nil)
            if nextPrayer == nil {
                nextPrayer = maghrib
            } else {
                otherPrayers.append(maghrib)
            }
        }

        if todaysPrayers.isha > currentTime {
            let isha: Prayer = ("Isha", todaysPrayers.isha, nil)
            if nextPrayer == nil {
                nextPrayer = isha
            } else {
                otherPrayers.append(isha)
            }
        }

        lastNightThird = Prayer("", lastThirdTime, nil)

        return nextPrayer
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
    var lastThirdTime: String {
        // calculate how long is the night
        let maghribTime = (
            hour: Int(todaysPrayers?.maghrib.split(separator: ":").first ?? "") ?? 0,
            minute: Int(todaysPrayers?.maghrib.split(separator: ":").last ?? "") ?? 0
        )

        let fajrTime = (
            hour: Int(todaysPrayers?.fajr.split(separator: ":").first ?? "") ?? 0,
            minute: Int(todaysPrayers?.fajr.split(separator: ":").last ?? "") ?? 0
        )

        var hoursDifference = differenceInHours(fajrTime.hour, maghribTime.hour)
        let minutesDifference = differenceInMinutes(fajrTime.minute,
                                                    maghribTime.minute,
                                                    &hoursDifference)
        let nightLong = (
            hour: hoursDifference,
            minute: minutesDifference
        )

        // calculate how long is the last third of the night
        let lastThirdNightLong = nightLong.hour / 3

        return "\(fajrTime.hour - lastThirdNightLong):00"
    }

    func differenceInMinutes(_ minute: Int, _ otherMinute: Int, _ hoursDifference: inout Int) -> Int {
        var minutesDifference = max(minute, otherMinute) - min(minute, otherMinute)
        if minutesDifference < 0 {
            minutesDifference += 60
            hoursDifference -= 1
        }

        return minutesDifference
    }

    func differenceInHours(_ hour: Int, _ otherHour: Int) -> Int {
        var hoursDifference = min(hour, otherHour) - max(hour, otherHour)
        if hoursDifference < 0 {
            hoursDifference += 24
            if hoursDifference == 24 {
                hoursDifference -= 1
            }
        }

        return hoursDifference
    }
}
