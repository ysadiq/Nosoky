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
        name.text = prayer.name
        time.text = "\(prayer.hour - 12):\(prayer.minute)"
        isHidden = false
    }
}
