//
//  DataProvider.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation
import CoreLocation

// API Doc: https://prayertimes.date/api/docs/this_month

class DataProvider {
    enum APIError: String, Error {
        case noNetwork = "No Network"
        case serverOverload = "Server is overloaded"
        case unableToDecode = "Failed to decode"
        case urlFailure = "Failed to build url"
    }
    var lastUpdated: Date?
    var completion: ((_ data: PrayerTimesModel.Results?, _ error: APIError?) -> Void)?

    func prayerTimes(for locationCoordinate: CLLocationCoordinate2D,
                     completion: @escaping (_ data: PrayerTimesModel.Results?, _ error: APIError?
                     ) -> Void) {
        self.completion = completion

        if let data = fetchPrayerTimesFromStorage() {
            parse(data)
            return
        }

        fetchPrayerTimesFromAPI(with: locationCoordinate) { [weak self] (data, error) in
            guard let data = data else {
                return
            }

            StorageManager.shared.save(data)
            self?.parse(data)
        }
    }

    private func fetchPrayerTimesFromAPI(
        with locationCoordinate: CLLocationCoordinate2D,
        completion: @escaping (_ data: Data?, _ error: Error?
        ) -> Void) {
        guard let url = URL(string: "https://api.pray.zone/v2/times/this_month.json?latitude=\(locationCoordinate.latitude)&longitude=\(locationCoordinate.longitude)&elevation=30&school=5") else {
            completion(nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, urlResponse, error in
            guard let data = data else {
                completion(nil, nil)
                return
            }

            completion(data, nil)
        }.resume()
    }

    private func fetchPrayerTimesFromStorage() -> Data? {
        StorageManager.shared.load()
    }

    private func parse(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(PrayerTimesModel.self, from: data).results

            lastUpdated = Date()
            completion?(result, nil)
        } catch {
            completion?(nil, .unableToDecode)
        }
    }
}
