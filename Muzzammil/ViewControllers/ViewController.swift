//
//  ViewController.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var prayerNameLabel: UILabel!
    @IBOutlet weak var prayerTimeLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet var otherPrayersStackView: [PrayerStackView]!

    lazy var viewModel = {
        ViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
    }

    func initViewModel() {
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
                }
            default:
                break
            }
        }

        viewModel.fetchData()
    }

    func updateNextPrayer() {
        guard let nextPrayer = viewModel.getNextPrayer() else {
            return
        }

        prayerNameLabel.text = nextPrayer.name
        prayerTimeLabel.text = nextPrayer.time
    }

    func updateOtherPrayers() {
        guard !viewModel.otherPrayers.isEmpty else {
            return
        }

        for (index, prayer) in viewModel.otherPrayers.enumerated() {
            otherPrayersStackView[index].name.text = prayer.name
            otherPrayersStackView[index].time.text = prayer.time
            otherPrayersStackView[index].isHidden = false
        }
    }

    func updateLastUpdated() {
        self.lastUpdatedDateLabel.text = self.viewModel.lastUpdated
        self.lastUpdatedLabel.isHidden = false
        self.lastUpdatedDateLabel.isHidden = false
    }
}

