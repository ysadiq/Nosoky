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
    lazy var lastUpdated: String? = {
        guard let lastUpdated = dataProvider.lastUpdated else {
            return nil
        }

        return DateHelper.string(from: lastUpdated, dateFormat: "EEEE, MMM d, yyyy")
    }()
    var contentState: ContentState = .empty {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    lazy var currentTime =  {
        DateHelper.string(dateFormat: "HH:mm")
    }()

    lazy var nextPrayer: Prayer? = {
        guard let todaysPrayers = dateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times else {
            return nil
        }

        if todaysPrayers.fajr > currentTime {
            return ("Fajr", todaysPrayers.fajr, nil)
        } else if todaysPrayers.sunrise > currentTime {
            return ("Sunrise", todaysPrayers.sunrise, nil)
        } else if todaysPrayers.dhuhr > currentTime {
            return ("Dhuhr", todaysPrayers.dhuhr, nil)
        } else if todaysPrayers.asr > currentTime {
            return ("Asr", todaysPrayers.asr, nil)
        } else if todaysPrayers.maghrib > currentTime {
            return ("Maghrib", todaysPrayers.maghrib, nil)
        } else if todaysPrayers.isha > currentTime {
            return ("Isha", todaysPrayers.isha, nil)
        }

        return ("Imsak", todaysPrayers.imsak, nil)
    }()

    lazy var otherPrayers: [Prayer] = {
        guard let todaysPrayers = dateTimes.filter({ dateTime in
            dateTime.date.gregorian == DateHelper.string()
        }).first?.times else {
            return []
        }

        var otherPrayers: [Prayer] = []

        if todaysPrayers.fajr != nextPrayer?.time {
            otherPrayers.append(("Fajr", todaysPrayers.fajr, nil))
        }

        if todaysPrayers.dhuhr != nextPrayer?.time {
            otherPrayers.append(("Dhuhr", todaysPrayers.dhuhr, nil))
        }

        if todaysPrayers.asr != nextPrayer?.time {
            otherPrayers.append(("Asr", todaysPrayers.asr, nil))
        }

        if todaysPrayers.maghrib != nextPrayer?.time {
            otherPrayers.append(("Maghrib", todaysPrayers.maghrib, nil))
        }

        if todaysPrayers.isha != nextPrayer?.time {
            otherPrayers.append(("Isha", todaysPrayers.isha, nil))
        }

        return otherPrayers
    }()

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
}
