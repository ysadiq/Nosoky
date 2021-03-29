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
                    self.prayerName.text = self.viewModel.nextPrayer?.prayerName
                    self.prayerTime.text = self.viewModel.nextPrayer?.time
                    self.lastUpdatedDate.text = self.viewModel.lastUpdated
                    self.lastUpdated.isHidden = false
                    self.lastUpdatedDate.isHidden = false
                }
            default:
                break
            }
        }

        viewModel.fetchData()
    }
}

