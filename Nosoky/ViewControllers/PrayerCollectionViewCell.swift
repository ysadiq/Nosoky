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
        guard let prayerTimeHour = prayer.time.hour, let prayerTimeMinute = prayer.time.minute else {
            return
        }

        var hourToSubtract: Int {
            prayerTimeHour > 12 ? 12 : 0
        }

        name.text = prayer.name
        time.text = "\(prayerTimeHour - hourToSubtract):\(prayerTimeMinute)"
        isHidden = false
    }
}
