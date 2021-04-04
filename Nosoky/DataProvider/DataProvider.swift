//
//  DataProvider.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit
import CoreLocation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case unableToDecode = "Failed to decode"
    case urlFailure = "Failed to build url"
}

protocol DataProviderProtocol {
    var lastUpdated: Date? { get }
    func prayerTimes(completion: @escaping (_ data: PrayerTimesModel.Results?, _ error: APIError?
                     ) -> Void)

}

// API Doc: https://prayertimes.date/api/docs/this_month

class DataProvider: NSObject, DataProviderProtocol {
    var locationManager: CLLocationManager? = CLLocationManager()

    var lastUpdated: Date?
    var completion: ((_ data: PrayerTimesModel.Results?, _ error: APIError?) -> Void)?
    private let notificationManager: NotificationManager

    init(notificationManager: NotificationManager = NotificationManager()) {
        self.notificationManager = notificationManager
    }

    func prayerTimes(completion: @escaping (_ data: PrayerTimesModel.Results?, _ error: APIError?
                     ) -> Void) {
        self.completion = completion

        if let data = fetchPrayerTimesFromStorage() {
            guard let prayerTimes = self.parse(data) else {
                completion(nil, .unableToDecode)
                return
            }

            completion(prayerTimes, nil)
            notificationManager.addNotificationsIfNeeded(for: prayerTimes.datetime)
            return
        }

        configureLocation()
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

            DispatchQueue.main.async {
                completion(data, nil)
            }
        }.resume()
    }

    private func fetchPrayerTimesFromStorage() -> Data? {
        StorageManager.shared.load()
    }

    private func parse(_ data: Data) -> PrayerTimesModel.Results? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(PrayerTimesModel.self, from: data).results

            lastUpdated = Date()
            return result
        } catch {
            return nil
        }
    }

    func configureLocation() {
        guard let locationManager = locationManager else {
            return
        }

        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
}

extension DataProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager = nil

        guard let currentLocation = locations.first else {
            return
        }

        fetchPrayerTimesFromAPI(with: currentLocation.coordinate) { [weak self] (data, error) in
            guard let data = data else {
                self?.completion?(nil, .noNetwork)
                return
            }

            StorageManager.shared.save(data)

            guard let prayerTimes = self?.parse(data) else {
                self?.completion?(nil, .unableToDecode)
                return
            }

            self?.completion?(prayerTimes, nil)
            self?.notificationManager.addNotificationsIfNeeded(for: prayerTimes.datetime)
        }
    }
}
