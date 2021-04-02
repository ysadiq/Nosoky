//
//  PrayerManagerMock.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/2/21.
//

import Foundation
@testable import Nosoky

class PrayerManagerMock: PrayerManager {
    override var currentTime: Time {
        ViewControllerTests.currentTime
    }

    override var lastNightThirdTime: Time? {
        get {
            (1,7)
        } set {
            _ = newValue
        }
    }
}
