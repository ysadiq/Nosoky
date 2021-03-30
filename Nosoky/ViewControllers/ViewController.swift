//
//  ViewController.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var nextPrayerTitleLabel: UILabel!
    @IBOutlet weak var prayerNameLabel: UILabel!
    @IBOutlet weak var prayerTimeLabel: UILabel!
    @IBOutlet weak var prayerTimeUnitLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet var otherPrayersStackView: [PrayerStackView]!
    @IBOutlet var lastThirdNightStackView: UIStackView!
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
              PrayerManager.shared.nextPrayer?.name != "Night" else {
            configureLastThirdNightView()
            return
        }

        prayerNameLabel.text = nextPrayer.name
        setPrayerTimeLabel(nextPrayer.time)
    }

    func updateOtherPrayers() {
        for (index, prayer) in PrayerManager.shared.otherPrayers.enumerated() {
            otherPrayersStackView[index].setup(prayer)
        }
    }

    func updateLastNightThird() {
        if let lastNightThirdTime = PrayerManager.shared.lastNightThirdTime {
            lastThirdNightTimeLabel.text = "\(lastNightThirdTime.hour):\(lastNightThirdTime.minute)"
        }
    }

    func updateLastUpdated() {
        lastUpdatedDateLabel.text = viewModel.lastUpdated
        lastUpdatedLabel.isHidden = false
        lastUpdatedDateLabel.isHidden = false

    }

    func configureLastThirdNightView() {
        guard let lastNightThirdTime = PrayerManager.shared.lastNightThirdTime else {
            return
        }

        nextPrayerTitleLabel.text = "The last third of the night starts in"
        setPrayerTimeLabel(lastNightThirdTime)

        prayerNameLabel.isHidden = true
        lastThirdNightStackView.isHidden = true
    }

    func setPrayerTimeLabel(_ time: Time) {
        let timeLeft = PrayerManager.shared.timeLeftTo(time)
        prayerTimeLabel.text = timeLeft.time.hour != 0 ? "\(timeLeft.time.hour):\(timeLeft.time.minute)" : "\(timeLeft.time.minute)"
        prayerTimeUnitLabel.text = timeLeft.timeUnit
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

