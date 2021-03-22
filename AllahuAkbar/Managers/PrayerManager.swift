//
//  PrayerManager.swift
//  AllahuAkbar
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

class PrayerManager {
    lazy var currentTime =  {
        DateHelper.string(dateFormat: "HH:mm")
    }()

    lazy var viewModel = {
        ViewModel()
    }()

    var nextPrayer: (prayerName: String, time: String)? {
        guard let todaysPrayers = viewModel.dateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times else {
            return nil
        }

        if todaysPrayers.imsak > currentTime {
            return ("Imsak", todaysPrayers.imsak)
        } else if todaysPrayers.fajr > currentTime {
            return ("Fajr", todaysPrayers.fajr)
        } else if todaysPrayers.sunrise > currentTime {
            return ("Sunrise", todaysPrayers.sunrise)
        } else if todaysPrayers.dhuhr > currentTime {
            return ("Dhuhr", todaysPrayers.dhuhr)
        } else if todaysPrayers.asr > currentTime {
            return ("Asr", todaysPrayers.asr)
        } else if todaysPrayers.maghrib > currentTime {
            return ("Maghrib", todaysPrayers.maghrib)
        }

        return ("Isha", todaysPrayers.isha)
    }
}
