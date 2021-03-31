//
//  PrayerCollectionViewCell.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import UIKit

class PrayerCollectionViewCell: UICollectionViewCell {
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
