//
//  PrayerManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

class PrayerManager {
    // MARK: - Initializer
    public static let shared = PrayerManager()
    init(minuteUpdateInterval: Double = 60) {
        self.minuteUpdateInterval = minuteUpdateInterval
    }

    // MARK: - Private properties
    private var todaysPrayers: [Prayer] = []
    private var tomorrowsPrayers: [Prayer] = []
    private var timer: Timer?

    // MARK: - Public properties
    var lastNightThirdTime: Time?
    let minuteUpdateInterval: Double
    var onMinuteUpdate: (() -> Void)? {
        willSet {
            if newValue == nil {
                stopCountdownTimer()
            } else {
                startCountdownTimer()
            }
        }
    }

    var prayerDateTimes: [Datetime] = [] {
        didSet {
            setTodaysPrayers()
            setTomorrowsPrayers()
        }
    }

    var tomorrowAsString = DateHelper.string(from: Date().addingTimeInterval(TimeInterval(60*60*24)))
    var todayAsString = DateHelper.string()
    var currentTime: Time {
        Time(
            hour: Calendar.current.dateComponents([.hour], from: Date()).hour,
            minute: Calendar.current.dateComponents([.minute], from: Date()).minute
        )
    }

    var nextPrayer: Prayer? {
        while let prayer = todaysPrayers.first {
            guard let prayerTimeHour = prayer.time.hour, let prayerTimeMinute = prayer.time.minute,
                  let currentTimeHour = currentTime.hour, let currentTimeMinute = currentTime.minute else {
                continue
            }

            if prayerTimeHour > currentTimeHour ||
                (prayerTimeHour == currentTimeHour && prayerTimeMinute > currentTimeMinute) {
                return prayer
            } else {
                todaysPrayers.removeFirst()
            }
        }

        return nil
    }

    var otherPrayers: [Prayer] {
        if let nextPrayer = nextPrayer {
            return todaysPrayers.filter { $0.name != nextPrayer.name }
        } else {
            return tomorrowsPrayers.filter { $0.name != "Isha" && $0.name != "Night" }
        }
    }

    // MARK: - Class methods
//    class func prayer(_ id: String, _ name: String, time: Time) -> Prayer {
//        let timeComponents = time.split(separator: ":")
//
//        guard let hour = timeComponents.first, let minute = timeComponents.last else {
//            return Prayer(id: id, name: name, time: Time(hour: 0, minute: 0))
//        }
//
//        return Prayer(id: id, name: name, time: Time(hour: Int(hour), minute: Int(minute)))
//    }

    // MARK: - Private methods
    private func setTodaysPrayers() {
        guard let prayers = prayerDateTimes.filter({ dateTime in
            dateTime.date.gregorian == todayAsString
        }).first?.times,
        let maghrib = prayers.maghrib,
        let fajr = prayers.fajr else {
            return
        }

        calculateLastThirdNightTime(maghribTime: maghrib.time, fajrTime: fajr.time)
        todaysPrayers = prayersList(of: prayers)
    }

    private func setTomorrowsPrayers() {
        // set tomorrow's prayer
        guard let prayers = prayerDateTimes.filter({ dateTime in
            dateTime.date.gregorian == tomorrowAsString
        }).first?.times else {
            // if tomorrow is a new month, get today's prayer too :)
            // I think there's not much difference
            if let prayers = prayerDateTimes.filter({ dateTime in
                dateTime.date.gregorian == todayAsString
            }).first?.times {
                tomorrowsPrayers = prayersList(of: prayers)
            }

            return
        }

        tomorrowsPrayers = prayersList(of: prayers)
    }

    func prayersList(of prayers: Times) -> [Prayer] {
        var prayersList: [Prayer] = []

        if let lastNightThirdTime = lastNightThirdTime {
            prayersList.append(Prayer(id: UUID().uuidString, name: "Night", time: lastNightThirdTime))
        }

        if let fajr = prayers.fajr {
            prayersList.append(fajr)
        }

        if let dhuhr = prayers.dhuhr {
            prayersList.append(dhuhr)
        }

        if let asr = prayers.asr {
            prayersList.append(asr)
        }

        if let maghrib = prayers.maghrib {
            prayersList.append(maghrib)
        }

        if let isha = prayers.isha {
            prayersList.append(isha)
        }

        return prayersList
    }

    /*
     calculate how long is the night
        Maghrib time 18:27
        Fajr time 4:27

        minutes 27 - 27 = 0
        hours 4 - 18 = -14+24 = 10 (subtract 1 if its 24 instead of 10)
        The night is 10 hours

     calculate how long is the last third of the night
        10/3 = 3.33 decimal
        3.33*60 = 200 minutes

     when does the 3rd part of the night start?
        4.27 - 3.33 =
        4 - 3 = 1
        27 - 33 = -6
        since the result is negative, add 60 to the minute and subtract 1 from the hour
            -6 + 60 = 54
            1 - 1 = 0
        the last third of the night starts at 00:54
    */
    private func calculateLastThirdNightTime(maghribTime: Time, fajrTime: Time) {
        // calculate how long is the night
        guard let maghribHour = maghribTime.hour,
              let maghribMinute = maghribTime.minute,
              let fajrHour = fajrTime.hour,
              let fajrMinute = fajrTime.minute else {
            return
        }

        let maghribTime = (hour: maghribHour, minute: maghribMinute)
        let fajrTime = (hour: fajrHour, minute: fajrMinute)

        var hoursDifference = differenceInHours(fajrTime.hour, maghribTime.hour)
        let minutesDifference = differenceInMinutes(fajrTime.minute, maghribTime.minute, &hoursDifference)

        let nightLong = (
            hour: hoursDifference,
            minute: minutesDifference
        )

        // calculate how long is the last third of the night
        let lastThirdNightLong = nightLong.hour / 3
        lastNightThirdTime = Time(hour: fajrTime.hour - lastThirdNightLong, minute: minutesDifference)
    }

    private func differenceInMinutes(_ minute: Int, _ otherMinute: Int, _ hoursDifference: inout Int) -> Int {
        var minutesDifference = minute - otherMinute
        if minutesDifference < 0 {
            minutesDifference += 60
            hoursDifference -= 1
        }

        return minutesDifference
    }

    private func differenceInHours(_ hour: Int, _ otherHour: Int) -> Int {
        var hoursDifference = hour - otherHour
        if hoursDifference < 0 {
            hoursDifference += 24
            if hoursDifference == 24 {
                hoursDifference -= 1
            }
        }

        return hoursDifference
    }

    // MARK: - Public methods
    public func timeRemainingTo(_ time: Time) -> (time: Time, timeUnit: String)? {
        guard let hour = time.hour, let minute = time.minute else {
            return nil
        }

        var hoursDifference = differenceInHours(hour,
                                                currentTime.hour ?? 0)
        let minutesDifference = differenceInMinutes(minute,
                                                    currentTime.minute ?? 0,
                                                    &hoursDifference)
        return (Time(hour: hoursDifference, minute: minutesDifference), hoursDifference > 0 ? "" : "min")
    }
}

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
