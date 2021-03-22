//
//  ViewModel.swift
//  AllahuAkbar
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

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
    var contentState: ContentState = .empty {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    lazy var currentTime =  {
        DateHelper.string(dateFormat: "HH:mm")
    }()

    lazy var nextPrayer: (prayerName: String, time: String)? = {
        guard let todaysPrayers = dateTimes.filter({ dateTime in
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
