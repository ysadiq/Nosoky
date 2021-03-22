//
//  ViewController.swift
//  AllahuAkbar
//
//  Created by Yahya Saddiq on 3/22/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var prayerName: UILabel!
    @IBOutlet weak var prayerTime: UILabel!

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
                }
            default:
                break
            }
        }

        viewModel.fetchData()
    }
}

