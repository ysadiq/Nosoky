//
//  Model.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

struct Model: Codable {
    let code: Int
    let status: String
    let results: Results
}

// MARK: - Results
struct Results: Codable {
    let datetime: [Datetime]
    let location: Location
    let settings: Settings
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
}

// MARK: - Times
struct Times: Codable {
    let imsak, sunrise, fajr, dhuhr: String
    let asr, sunset, maghrib, isha: String
    let midnight: String

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
