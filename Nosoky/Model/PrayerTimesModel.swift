//
//  Model.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

struct PrayerTimesModel: Codable {
    let code: Int
    let status: String
    let results: Results

    // MARK: - Results
    struct Results: Codable {
        let datetime: [Datetime]
        let location: Location
        let settings: Settings
    }
}

struct Prayer: Codable {
    var name: String
    let time: Time
    let isMandatory: Bool
}

struct Time: Codable {
    let hour, minute: Int?
}


// MARK: - Datetime
struct Datetime: Codable {
    let times: Times
    let date: DateClass
}

// MARK: - DateClass
struct DateClass: Codable {
    let timestamp: Int
    let gregorian, hijri: String
    let isMonday, isThursday: Bool
    let isWhiteDay, isAshura, isFirstSixDaysOfShawal: Bool
    let isArafa, isFirstNineDaysOfHij: Bool

    enum CodingKeys: String, CodingKey {
        case timestamp
        case gregorian
        case hijri
        case isMonday
        case isThursday
        case isWhiteDay
        case isAshura
        case isFirstSixDaysOfShawal
        case isArafa
        case isFirstNineDaysOfHij
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        timestamp = try container.decode(Int.self, forKey: .timestamp)
        gregorian = try container.decode(String.self, forKey: .gregorian)
        hijri = try container.decode(String.self, forKey: .hijri)

        let hijriDateString = try container.decode(String.self, forKey: .hijri).split(separator: "-")
        let hijriDateComponents = DateComponents(calendar: Calendar.init(identifier: .islamic), year: Int(hijriDateString[0]), month: Int(hijriDateString[1]), day: Int(hijriDateString[2]))
        let isRamadan = hijriDateComponents.month == 9

        if let hijriDate = hijriDateComponents.date {
            let day = DateHelper.string(from: hijriDate, dateFormat: "EEEE", calendar: .islamic)
            isMonday = day == "Monday" && !isRamadan
            isThursday = day == "Thursday" && !isRamadan
        } else {
            isMonday = false
            isThursday = false
        }
        isWhiteDay = [13, 14, 15].contains(hijriDateComponents.day) && !isRamadan
        isAshura = [9, 10].contains(hijriDateComponents.day) && hijriDateComponents.month == 1
        isFirstSixDaysOfShawal = (2...7) ~= hijriDateComponents.day ?? 0 && hijriDateComponents.month == 8
        isArafa = hijriDateComponents.day == 9 && hijriDateComponents.month == 12
        isFirstNineDaysOfHij = (1...9) ~= hijriDateComponents.day ?? 0 && hijriDateComponents.month == 12
    }
}

// MARK: - Times
struct Times: Codable {
    let imsak, sunrise, fajr, dhuhr: Prayer?
    let asr, sunset, maghrib, isha: Prayer?
    let midnight, night: Prayer?

    enum CodingKeys: String, CodingKey {
        case imsak = "Imsak"
        case sunrise = "Sunrise"
        case fajr = "Fajr"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case sunset = "Sunset"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case midnight = "Midnight"
        case night = "Night"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let imsakTime = try? container.decode(String.self, forKey: .imsak).split(separator: ":")
        self.imsak = Prayer(
            name: CodingKeys.imsak.rawValue,
            time: Time(hour: Int(imsakTime?.first ?? "0"),
                       minute: Int(imsakTime?.last ?? "0")),
            isMandatory: false
        )

        let fajrTime = try? container.decode(String.self, forKey: .fajr).split(separator: ":")
        self.fajr = Prayer(
            name: CodingKeys.fajr.rawValue,
            time: Time(hour: Int(fajrTime?.first ?? "0"),
                       minute: Int(fajrTime?.last ?? "0")),
            isMandatory: true
        )

        let sunriseTime = try? container.decode(String.self, forKey: .sunrise).split(separator: ":")
        self.sunrise = Prayer(
            name: CodingKeys.sunrise.rawValue,
            time: Time(hour: Int(sunriseTime?.first ?? "0"),
                       minute: Int(sunriseTime?.last ?? "0")),
            isMandatory: false
        )

        let dhuhrTime = try? container.decode(String.self, forKey: .dhuhr).split(separator: ":")
        self.dhuhr = Prayer(
            name: CodingKeys.dhuhr.rawValue,
            time: Time(hour: Int(dhuhrTime?.first ?? "0"),
                       minute: Int(dhuhrTime?.last ?? "0")),
            isMandatory: true
        )

        let asrTime = try? container.decode(String.self, forKey: .asr).split(separator: ":")
        self.asr = Prayer(
            name: CodingKeys.asr.rawValue,
            time: Time(hour: Int(asrTime?.first ?? "0"),
                       minute: Int(asrTime?.last ?? "0")),
            isMandatory: true
        )

        let maghribTime = try? container.decode(String.self, forKey: .maghrib).split(separator: ":")
        self.maghrib = Prayer(
            name: CodingKeys.maghrib.rawValue,
            time: Time(hour: Int(maghribTime?.first ?? "0"),
                       minute: Int(maghribTime?.last ?? "0")),
            isMandatory: true
        )

        let ishaTime = try? container.decode(String.self, forKey: .isha).split(separator: ":")
        self.isha = Prayer(
            name: CodingKeys.isha.rawValue,
            time: Time(hour: Int(ishaTime?.first ?? "0"),
                       minute: Int(ishaTime?.last ?? "0")),
            isMandatory: true
        )

        let sunsetTime = try? container.decode(String.self, forKey: .sunset).split(separator: ":")
        self.sunset = Prayer(
            name: CodingKeys.sunset.rawValue,
            time: Time(hour: Int(sunsetTime?.first ?? "0"),
                       minute: Int(sunsetTime?.last ?? "0")),
            isMandatory: false
        )

        let midnightTime = try? container.decode(String.self, forKey: .midnight).split(separator: ":")
        self.midnight = Prayer(
            name: CodingKeys.midnight.rawValue,
            time: Time(hour: Int(midnightTime?.first ?? "0"),
                       minute: Int(midnightTime?.last ?? "0")),
            isMandatory: false
        )

        let nightTime = PrayerManager.lastThirdNightTime(maghribTime: maghrib?.time, fajrTime: fajr?.time)
        self.night = Prayer(
            name: CodingKeys.night.rawValue,
            time: Time(hour: Int(nightTime?.hour ?? 0),
                       minute: Int(nightTime?.minute ?? 0)),
            isMandatory: false
        )
    }
}

// MARK: - Location
struct Location: Codable {
    let latitude, longitude: Double
    let elevation: Int
    let country, countryCode, timezone: String
    let localOffset: Int

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, elevation, country
        case countryCode = "country_code"
        case timezone
        case localOffset = "local_offset"
    }
}

// MARK: - Settings
struct Settings: Codable {
    let timeformat, school, juristic, highlat: String
    let fajrAngle, ishaAngle: Int

    enum CodingKeys: String, CodingKey {
        case timeformat, school, juristic, highlat
        case fajrAngle = "fajr_angle"
        case ishaAngle = "isha_angle"
    }
}
