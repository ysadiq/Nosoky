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
    @IBOutlet var otherPrayersCollectionView: UICollectionView!
    @IBOutlet var lastThirdNightStackView: UIStackView!
    @IBOutlet var lastThirdNightTimeLabel: UILabel!

    let locationManager = CLLocationManager()
    var currentCoordination: CLLocationCoordinate2D?

    lazy var viewModel = {
        ViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        otherPrayersCollectionView.delegate = self
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
                    self.updateLastUpdated()
                    self.updateLastNightThird()
                    self.otherPrayersCollectionView.reloadData()
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

    func updateLastNightThird() {
        if let lastNightThirdTimeHour = PrayerManager.shared.lastNightThirdTime?.hour,
           let lastNightThirdTimeMinute = PrayerManager.shared.lastNightThirdTime?.minute {
            lastThirdNightTimeLabel.text = "\(lastNightThirdTimeHour):\(lastNightThirdTimeMinute)"
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
        guard let timeLeft = PrayerManager.shared.timeLeftTo(time),
              let timeLeftHour = timeLeft.time.hour,
              let timeLeftMinute = timeLeft.time.minute else {
            return
        }
        
        prayerTimeLabel.text = timeLeftHour != 0 ? "\(timeLeftHour):\(timeLeftMinute)" : "\(timeLeftMinute)"

        if !timeLeft.timeUnit.isEmpty {
            prayerTimeUnitLabel.text = timeLeft.timeUnit
            prayerTimeUnitLabel.isHidden = false
        }
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

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        PrayerManager.shared.otherPrayers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "prayerCell",
            for: indexPath) as? PrayerCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.setup(PrayerManager.shared.otherPrayers[indexPath.row])
        return cell
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let CellWidth = 60
        let CellCount = PrayerManager.shared.otherPrayers.count
        let CellSpacing = 20

        let totalCellWidth = CellWidth * CellCount
        let totalSpacingWidth = CellSpacing * (CellCount - 1)

        let leftInset = (otherPrayersCollectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
