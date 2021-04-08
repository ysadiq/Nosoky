//
//  ViewModel.swift
//  Nosoky
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
    private let dataProvider: DataProviderProtocol
    private let prayerManager: PrayerManager
    private let fastingManager: FastingManager
    var updateLoadingStatus: [(() -> Void)?] = [] 
    var lastUpdated: String? {
        guard let lastUpdated = dataProvider.lastUpdated else {
            return nil
        }

        return DateHelper.string(from: lastUpdated, dateFormat: "MMMM yyyy")
    }

    var contentState: ContentState = .empty {
        didSet {
            updateLoadingStatus.forEach {
                $0?()
            }
        }
    }

    init(dataProvider: DataProviderProtocol = DataProvider(),
         prayerManager: PrayerManager = PrayerManager.shared,
         fastingManager: FastingManager = FastingManager.shared) {
        self.dataProvider = dataProvider
        self.prayerManager = prayerManager
        self.fastingManager = fastingManager
    }

    func fetchData() {
        contentState = .loading

        dataProvider.prayerTimes() { [weak self] result, error in
            guard let self = self,
                  let result = result else {
                return
            }

            self.fastingManager.dates = result.datetime.map { $0.date }
            self.prayerManager.prayerDateTimes = result.datetime
            self.contentState = .populated
        }
    }
}
