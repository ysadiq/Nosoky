//
//  PrayerStackView.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/29/21.
//

import UIKit

class PrayerStackView: UIStackView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!

    func setup(_ prayer: Prayer) {
        var hourToSubtract: Int {
            prayer.time.hour > 12 ? 12 : 0
        }

        name.text = prayer.name
        time.text = "\(prayer.time.hour - hourToSubtract):\(prayer.time.minute)"
        isHidden = false
    }
}
