//
//  PrayerManagerMock.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/2/21.
//

import Foundation
@testable import Nosoky

class PrayerManagerMock: PrayerManager {
    var currentTimeMock = Time(hour: 3, minute: 0)
    override var currentTime: Time {
        currentTimeMock
    }

    override var lastNightThirdTime: Time? {
        get {
            Time(hour: 1, minute: 7)
        } set {
            _ = newValue
        }
    }
}
