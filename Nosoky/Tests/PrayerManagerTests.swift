//
//  PrayerManagerTests.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 4/2/21.
//

import XCTest
@testable import Nosoky

class PrayerManagerTests: XCTestCase {
    var prayerManager: PrayerManagerMock!

    override func setUp() {
        super.setUp()

        prayerManager = PrayerManagerMock(minuteUpdateInterval: 1)
    }

    override func tearDown() {
        prayerManager = nil

        super.tearDown()
    }

    func testPrayer() {
        let prayer = Prayer(id: "", name: "Asr", time: Time(hour: 3, minute: 52))

        XCTAssertEqual(prayer.name, "Asr")
        XCTAssertEqual(prayer.time.hour, 3)
        XCTAssertEqual(prayer.time.minute, 52)
    }

    func testNightPrayer() {
        fetch(at: Time(hour: 20, minute: 0))
        XCTAssertNil(prayerManager.nextPrayer)

        XCTAssertEqual(prayerManager.otherPrayers.count, 4)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Fajr")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Dhuhr")
        XCTAssertEqual(prayerManager.otherPrayers[2].name, "Asr")
        XCTAssertEqual(prayerManager.otherPrayers[3].name, "Maghrib")
    }

    func testFajrPrayer() {
        fetch(at: Time(hour: 3, minute: 0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Fajr")

        XCTAssertEqual(prayerManager.otherPrayers.count, 4)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Dhuhr")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Asr")
        XCTAssertEqual(prayerManager.otherPrayers[2].name, "Maghrib")
        XCTAssertEqual(prayerManager.otherPrayers[3].name, "Isha")
    }

    func testDhuhurPrayer() {
        fetch(at: Time(hour: 11, minute: 0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Dhuhr")

        XCTAssertEqual(prayerManager.otherPrayers.count, 3)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Asr")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Maghrib")
        XCTAssertEqual(prayerManager.otherPrayers[2].name, "Isha")
    }

    func testAsrPrayer() {
        fetch(at: Time(hour: 14, minute: 0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Asr")

        XCTAssertEqual(prayerManager.otherPrayers.count, 2)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Maghrib")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Isha")
    }

    func testMaghribPrayer() {
        fetch(at: Time(hour: 16, minute: 0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Maghrib")

        XCTAssertEqual(prayerManager.otherPrayers.count, 1)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Isha")
    }

    func testIshaPrayer() {
        fetch(at: Time(hour: 19, minute: 0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Isha")
        XCTAssertTrue(prayerManager.otherPrayers.isEmpty)
    }

    func testPrayerDateTimes() {
        prayerManager.currentTimeMock = Time(hour: 2, minute:0)
        prayerManager.prayerDateTimes = [
            Datetime(
                times: Times(JSONString: "{\"times\":{\"Imsak\":\"\",\"Sunrise\":\"\",\"Fajr\":\"05:00\",\"Dhuhr\":\"\",\"Asr\":\"\",\"Sunset\":\"\",\"Maghrib\":\"\",\"Isha\":\"\",\"Midnight\":\"\"}}")!,
                date: DateClass(
                    timestamp: 1,
                    gregorian: DateHelper.string(from: Date()),
                    hijri: "")
            )]

        XCTAssertEqual(prayerManager.nextPrayer?.name, "Fajr")
        XCTAssertEqual(prayerManager.otherPrayers.count, 4)
    }

    func testOnMinuteUpdate() {
        let expectation = XCTestExpectation(description: #function)
        prayerManager.onMinuteUpdate = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testCancelOnMinuteUpdate() {
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        prayerManager.onMinuteUpdate = nil
        wait(for: [expectation], timeout: 1)
    }

    func testLastNightThirdTime() {
        prayerManager.currentTimeMock = Time(hour: 2, minute:0)
        prayerManager.prayerDateTimes = [
            Datetime(
                times: Times(JSONString: "{\"times\":{\"Imsak\":\"\",\"Sunrise\":\"\",\"Fajr\":\"04:00\",\"Dhuhr\":\"\",\"Asr\":\"\",\"Sunset\":\"\",\"Maghrib\":\"18:00\",\"Isha\":\"\",\"Midnight\":\"\"}}")!,
                date: DateClass(
                    timestamp: 1,
                    gregorian: DateHelper.string(from: Date()),
                    hijri: "")
            )]

        XCTAssertEqual(prayerManager.lastNightThirdTime?.hour, 1)
        XCTAssertEqual(prayerManager.lastNightThirdTime?.minute, 7)
    }
}

// MARK: - Helper methods
extension PrayerManagerTests {
    func fetch(at time: Time) {
        prayerManager.currentTimeMock = Time(hour: time.hour!, minute: time.minute!)
        let promise = XCTestExpectation(description: #function)
        DataProviderMock().prayerTimes(for: nil) { result, error in
            self.prayerManager.prayerDateTimes = result!.datetime
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
    }
}
