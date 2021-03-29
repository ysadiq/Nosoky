//
//  PrayerManager.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

class PrayerManager {
    public static let shared = PrayerManager()
    private init() {}

    var prayerDateTimes: [Datetime] = []
    var nextPrayer: Prayer?
    var otherPrayers: [Prayer] = []
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

        var prayer: Prayer?

        if todaysPrayers.fajr > currentTime {
            prayer = ("Fajr", todaysPrayers.fajr, nil)
        }

        if todaysPrayers.sunrise > currentTime {
            let sunrise: Prayer = ("Sunrise", todaysPrayers.sunrise, nil)
            if prayer == nil {
                prayer = sunrise
            } else {
                otherPrayers.append(sunrise)
            }
        }

        if todaysPrayers.dhuhr > currentTime {
            let dhuhr: Prayer = ("Dhuhr", todaysPrayers.dhuhr, nil)
            if prayer == nil {
                prayer = dhuhr
            } else {
                otherPrayers.append(dhuhr)
            }
        }

        if todaysPrayers.asr > currentTime {
            let asr: Prayer = ("Asr", todaysPrayers.asr, nil)
            if prayer == nil {
                prayer = asr
            } else {
                otherPrayers.append(asr)
            }
        }

        if todaysPrayers.maghrib > currentTime {
            let maghrib: Prayer = ("Maghrib", todaysPrayers.maghrib, nil)
            if prayer == nil {
                prayer = maghrib
            } else {
                otherPrayers.append(maghrib)
            }
        }

        if todaysPrayers.isha > currentTime {
            let isha: Prayer = ("Isha", todaysPrayers.isha, nil)
            if prayer == nil {
                prayer = isha
            } else {
                otherPrayers.append(isha)
            }
        }

        return prayer
    }
}
