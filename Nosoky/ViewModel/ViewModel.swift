//
//  ViewModel.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation
import CoreLocation

public enum ContentState {
    case loading
    case error
    case empty
    case populated
}

class ViewModel {
    private let dataProvider = DataProvider()
    var updateLoadingStatus: (() -> Void)?
    var lastUpdated: String? {
        guard let lastUpdated = dataProvider.lastUpdated else {
            return nil
        }

        return DateHelper.string(from: lastUpdated, dateFormat: "MMM yyyy")
    }

    var contentState: ContentState = .empty {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    func fetchData(with locationCoordinate: CLLocationCoordinate2D) {
        contentState = .loading

        dataProvider.prayerTimes(for: locationCoordinate) { [weak self] result, error in
            guard let self = self,
                  let result = result else {
                return
            }

            PrayerManager.shared.prayerDateTimes = result.datetime
            self.contentState = .populated
        }
    }
}
