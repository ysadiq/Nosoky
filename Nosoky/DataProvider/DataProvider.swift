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

    func fetchPrayerTimes(with locationCoordinate: CLLocationCoordinate2D, completion: @escaping (_ data: Results?, _ error: APIError?) -> Void) {
        guard let url = URL(string: "https://api.pray.zone/v2/times/this_month.json?latitude=\(locationCoordinate.latitude)&longitude=\(locationCoordinate.longitude)&elevation=30&school=5") else {
            completion(nil, .urlFailure)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(Model.self, from: data).results
                self?.lastUpdated = Date()
                completion(result, nil)
            } catch {
                completion(nil, .unableToDecode)
            }
        }
        .resume()
    }
}
