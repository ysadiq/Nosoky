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
