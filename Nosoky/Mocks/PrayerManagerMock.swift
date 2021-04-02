//
//  PrayerManagerMock.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/2/21.
//

import Foundation

class PrayerManagerMock: PrayerManager {
    override var currentTime: Time {
        (3,0)
    }

    override var lastNightThirdTime: Time? {
        get {
            (1,7)
        } set {
            _ = newValue
        }
    }
}
