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
        prayerManager.todayAsString = "2021-04-01"
    }

    override func tearDown() {
        prayerManager = nil

        super.tearDown()
    }

    func testPrayer() {
        let prayer = Prayer(id: "", name: "Asr", time: Time(hour: 3, minute: 52), isMandatory: true)

        XCTAssertEqual(prayer.name, "Asr")
        XCTAssertEqual(prayer.time.hour, 3)
        XCTAssertEqual(prayer.time.minute, 52)
    }

    func testNightPrayer() {
        fetch(at: Time(hour: 20, minute: 0))
        XCTAssertNil(prayerManager.nextPrayer)

        XCTAssertEqual(prayerManager.otherPrayers.count, 5)
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
        prayerManager.prayerDateTimes =
            PrayerTimesModel(JSONString: "{\"code\":200,\"status\":\"OK\",\"results\":{\"datetime\":[{\"times\":{\"Imsak\":\"04:13\",\"Sunrise\":\"05:43\",\"Fajr\":\"05:00\",\"Dhuhr\":\"11:58\",\"Asr\":\"15:30\",\"Sunset\":\"18:14\",\"Maghrib\":\"18:14\",\"Isha\":\"19:34\",\"Midnight\":\"23:59\"},\"date\":{\"timestamp\":1617235200,\"gregorian\":\"2021-04-01\",\"hijri\":\"1442-08-19\"}}],\"location\":{\"latitude\":30.086594,\"longitude\":31.3445356,\"elevation\":30,\"country\":\"\",\"country_code\":\"EG\",\"timezone\":\"Africa/Cairo\",\"local_offset\":2},\"settings\":{\"timeformat\":\"HH:mm\",\"school\":\"Egyptian General Authority of Survey\",\"juristic\":\"Shafii\",\"highlat\":\"None\",\"fajr_angle\":18,\"isha_angle\":18}}}")!.results.datetime

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
        DataProviderMock().prayerTimes { result, error in
            self.prayerManager.prayerDateTimes = result!.datetime
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
    }
}
