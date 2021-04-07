//
//  PrayerManager+Counter.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/7/21.
//

import Foundation

// MARK: - Countdown Timer
extension PrayerManager {
    func startCountdownTimer() {
        guard timer == nil,
              onMinuteUpdate == nil else {
            return
        }

        timer = Timer.scheduledTimer(
            timeInterval: minuteUpdateInterval,
            target: self,
            selector: #selector(executeOnMinuteUpdate),
            userInfo: nil,
            repeats: true)
    }

    func stopCountdownTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func executeOnMinuteUpdate() {
        onMinuteUpdate?()
    }
}
