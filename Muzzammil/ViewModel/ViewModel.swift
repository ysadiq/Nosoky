//
//  ViewModel.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

typealias Prayer = (name: String, time: String, timeLeft: String?)

public enum ContentState {
    case loading
    case error
    case empty
    case populated
}

class ViewModel {
    private let dataProvider = DataProvider()
    private(set) var dateTimes: [Datetime] = []
    var updateLoadingStatus: (() -> Void)?
    var lastUpdated: String? {
        guard let lastUpdated = dataProvider.lastUpdated else {
            return nil
        }

        return DateHelper.string(from: lastUpdated, dateFormat: "EEEE, MMM d, yyyy")
    }

    var contentState: ContentState = .empty {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    lazy var currentTime =  {
        DateHelper.string(dateFormat: "HH:mm")
    }()

    lazy var todaysPrayers: Times? = {
        dateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times
    }()

    var nextPrayer: Prayer?
    var otherPrayers: [Prayer] = []

    func fetchData() {
        contentState = .loading

        dataProvider.fetchPrayerTimes { [weak self] result, error in
            guard let self = self,
                  let result = result else {
                return
            }

            self.dateTimes = result.datetime
            self.contentState = .populated
        }
    }

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
