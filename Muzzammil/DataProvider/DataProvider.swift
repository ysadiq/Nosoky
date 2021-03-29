//
//  DataProvider.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

// API Doc: https://prayertimes.date/api/docs/this_month

class DataProvider {
    enum APIError: String, Error {
        case noNetwork = "No Network"
        case serverOverload = "Server is overloaded"
        case notFound = "Page Not Found"
    }

    var lastUpdated: Date?

    func fetchPrayerTimes(completion: @escaping (_ data: Results?, _ error: APIError?) -> Void) {
        guard let url = URL(string: "https://api.pray.zone/v2/times/this_month.json?latitude=30.0865936&longitude=31.3445356&elevation=30&school=5") else {
            completion(nil, .notFound)
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
                completion(nil, .notFound)
            }
        }
        .resume()
    }
}
