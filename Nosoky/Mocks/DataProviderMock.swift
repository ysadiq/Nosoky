//
//  DataProviderMock.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/1/21.
//

import Foundation
import CoreLocation

class DataProviderMock: DataProviderProtocol {
    var lastUpdated: Date?

    func prayerTimes(completion: @escaping (PrayerTimesModel.Results?, APIError?) -> Void) {
        guard let url = Bundle(for: DataProviderMock.self).url(forResource: "april", withExtension: "json") else {
            completion(nil, APIError.noNetwork)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(PrayerTimesModel.self, from: data).results

                self.lastUpdated = DateHelper.date(from: "2021-03-01")
                completion(result, nil)
            } catch {
                completion(nil, APIError.unableToDecode)
            }
        }
    }
}
