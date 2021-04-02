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

    func prayerTimes(for locationCoordinate: CLLocationCoordinate2D, completion: @escaping (PrayerTimesModel.Results?, APIError?) -> Void) {
        let fileName = DateHelper.string(dateFormat: "MMMM_yyyy")
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).json") else {
            completion(nil, APIError.noNetwork)
            return
        }

        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(PrayerTimesModel.self, from: data).results

            lastUpdated = Date()
            completion(result, nil)
        } catch {
            completion(nil, APIError.unableToDecode)
        }
    }
}
