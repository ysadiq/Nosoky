//
//  ViewController.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit

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

    lazy var viewModel = {
        ViewModel(prayerManager: prayerManager)
    }()
    lazy var prayerManager = {
        PrayerManager.shared
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        prayerManager.onMinuteUpdate = { [weak self] in
            self?.updateNextPrayer()
        }
        initViewModel()
    }

    func initViewModel() {
        let updateLoadingStatus = { [weak self] in
            guard let self = self else {
                return
            }

            switch self.viewModel.contentState {
            case .populated:
                self.updateNextPrayer()
                self.updateLastUpdated()
                self.updateLastNightThird()
                self.otherPrayersCollectionView.reloadData()
            default:
                break
            }
        }
        
        viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewModel.fetchData()
    }

    func updateNextPrayer() {
        let nextPrayer = prayerManager.nextPrayer
        
        if nextPrayer.name == "Night" {
            nextPrayerTitleLabel.text = "The last third of the night starts in"
            setPrayerTimeLabel(nextPrayer.time)
            prayerNameLabel.isHidden = true
            lastThirdNightStackView.isHidden = true

            otherPrayersCollectionView.reloadData()
            return
        } else if nextPrayerTitleLabel.text == "The last third of the night starts in" {
            nextPrayerTitleLabel.text = "Next Prayer"
            prayerNameLabel.text = nextPrayer.name
            prayerNameLabel.isHidden = false
            lastThirdNightStackView.isHidden = false

            otherPrayersCollectionView.reloadData()
        }

        if nextPrayer.name != prayerNameLabel.text {
            prayerNameLabel.text = nextPrayer.name
            otherPrayersCollectionView.reloadData()
        }
        
        setPrayerTimeLabel(nextPrayer.time)
    }

    func updateLastNightThird() {
        if let lastNightThirdTimeHour = prayerManager.lastNightThirdTime?.hour,
           let lastNightThirdTimeMinute = prayerManager.lastNightThirdTime?.minute {
            lastThirdNightTimeLabel.text = "\(lastNightThirdTimeHour):\(lastNightThirdTimeMinute)"
        }
    }

    func updateLastUpdated() {
        lastUpdatedDateLabel.text = viewModel.lastUpdated
        lastUpdatedLabel.isHidden = false
        lastUpdatedDateLabel.isHidden = false

    }

    func setPrayerTimeLabel(_ time: Time) {
        guard let timeRemaining = prayerManager.timeRemainingTo(time),
              let timeRemainingHour = timeRemaining.time.hour,
              let timeRemainingMinute = timeRemaining.time.minute else {
            return
        }

        prayerTimeLabel.text = timeRemainingHour == 0 ? "\(timeRemainingMinute)" : "\(timeRemainingHour):\(timeRemainingMinute)"

        prayerTimeUnitLabel.text = timeRemaining.timeUnit
        prayerTimeUnitLabel.isHidden = timeRemaining.timeUnit.isEmpty
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(prayerManager.otherPrayers.count, 4)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "prayerCell",
            for: indexPath) as? PrayerCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.setup(prayerManager.otherPrayers[indexPath.row])
        return cell
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let CellWidth = 60
        let CellCount = otherPrayersCollectionView.numberOfItems(inSection: 0)
        let CellSpacing = 20

        let totalCellWidth = CellWidth * CellCount
        let totalSpacingWidth = CellSpacing * (CellCount - 1)

        let leftInset = (otherPrayersCollectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
