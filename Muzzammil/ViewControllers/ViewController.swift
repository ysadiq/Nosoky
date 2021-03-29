//
//  ViewController.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var prayerName: UILabel!
    @IBOutlet weak var prayerTime: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    @IBOutlet weak var lastUpdatedDate: UILabel!
    @IBOutlet var otherPrayers: [PrayerStackView]!

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
                    self.updateLastUpdate()
                }
            default:
                break
            }
        }

        viewModel.fetchData()
    }

    func updateNextPrayer() {
        prayerName.text = viewModel.nextPrayer?.name
        prayerTime.text = viewModel.nextPrayer?.time
    }

    func updateOtherPrayers() {
        for (index, prayer) in viewModel.otherPrayers.enumerated() {
            otherPrayers[index].name.text = prayer.name
            otherPrayers[index].time.text = prayer.time
        }
    }

    func updateLastUpdate() {
        self.lastUpdatedDate.text = self.viewModel.lastUpdated
        self.lastUpdated.isHidden = false
        self.lastUpdatedDate.isHidden = false
    }
}

