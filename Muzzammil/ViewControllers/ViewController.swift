//
//  ViewController.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var prayerNameLabel: UILabel!
    @IBOutlet weak var prayerTimeLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet var otherPrayersStackView: [PrayerStackView]!
    @IBOutlet var lastThirdNightTimeLabel: UILabel!

    let locationManager = CLLocationManager()
    var currentCoordination: CLLocationCoordinate2D?

    lazy var viewModel = {
        ViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        startShimmering()
        configureLocation()
    }

    func initViewModel(with locationCoordinate: CLLocationCoordinate2D) {
        viewModel.updateLoadingStatus = { [weak self] in
            guard let self = self else {
                return
            }

            switch self.viewModel.contentState {
            case .populated:
                DispatchQueue.main.async {
                    self.updateNextPrayer()
                    self.updateOtherPrayers()
                    self.updateLastUpdated()
                    self.updateLastNightThird()
                    self.stopShimmering()
                }
            default:
                break
            }
        }

        viewModel.fetchData(with: locationCoordinate)
    }

    func updateNextPrayer() {
        guard let nextPrayer = PrayerManager.shared.nextPrayer,
              let timeLeft = PrayerManager.shared.timeLeftToNextPrayer else {
            return
        }

        prayerNameLabel.text = nextPrayer.name
        prayerTimeLabel.text = "\(timeLeft.hour):\(timeLeft.minute)"
    }

    func updateOtherPrayers() {
        guard let otherPrayers = PrayerManager.shared.otherPrayers,
              !otherPrayers.isEmpty else {
            return
        }

        for (index, prayer) in otherPrayers.enumerated() {
            otherPrayersStackView[index].name.text = prayer.name
            otherPrayersStackView[index].time.text = prayer.time
            otherPrayersStackView[index].isHidden = false
        }
    }

    func updateLastNightThird() {
        lastThirdNightTimeLabel.text = PrayerManager.shared.lastNightThird
    }

    func updateLastUpdated() {
        self.lastUpdatedDateLabel.text = self.viewModel.lastUpdated
        self.lastUpdatedLabel.isHidden = false
        self.lastUpdatedDateLabel.isHidden = false
    }

    func startShimmering() {

    }

    func stopShimmering() {

    }

    func configureLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else {
            return
        }

        initViewModel(with: currentLocation.coordinate)
    }
}

