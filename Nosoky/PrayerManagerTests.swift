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

        prayerManager = PrayerManagerMock()
    }

    override func tearDown() {
        prayerManager = nil

        super.tearDown()
    }

    func testPrayer() {
        let prayer = PrayerManager.prayer("Asr", time: "3:52")

        XCTAssertEqual(prayer.name, "Asr")
        XCTAssertEqual(prayer.time.hour, 3)
        XCTAssertEqual(prayer.time.minute, 52)
    }

    func fetch(at time: Time) {
        prayerManager.currentTimeMock = (time.hour!, time.minute!)
        let promise = XCTestExpectation(description: #function)
        DataProviderMock().prayerTimes(for: nil) { result, error in
            self.prayerManager.prayerDateTimes = result!.datetime
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
    }

    func testFajrPrayer() {
        fetch(at: (3,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Fajr")
    }

    func testNightPrayer() {
        fetch(at: (20,0))
        XCTAssertNil(prayerManager.nextPrayer)
    }

    func testDhuhurPrayer() {
        fetch(at: (11,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Dhuhur")
    }

    func testAsrPrayer() {
        fetch(at: (14,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Asr")
    }

    func testMaghribPrayer() {
        fetch(at: (16,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Maghrib")
    }

    func testIshaPrayer() {
        fetch(at: (19,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Isha")
    }
}
