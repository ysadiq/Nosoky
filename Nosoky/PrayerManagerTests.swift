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

    func testNightPrayer() {
        fetch(at: (20,0))
        XCTAssertNil(prayerManager.nextPrayer)

        XCTAssertEqual(prayerManager.otherPrayers.count, 4)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Fajr")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Dhuhur")
        XCTAssertEqual(prayerManager.otherPrayers[2].name, "Asr")
        XCTAssertEqual(prayerManager.otherPrayers[3].name, "Maghrib")
    }

    func testFajrPrayer() {
        fetch(at: (3,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Fajr")

        XCTAssertEqual(prayerManager.otherPrayers.count, 4)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Dhuhur")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Asr")
        XCTAssertEqual(prayerManager.otherPrayers[2].name, "Maghrib")
        XCTAssertEqual(prayerManager.otherPrayers[3].name, "Isha")
    }

    func testDhuhurPrayer() {
        fetch(at: (11,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Dhuhur")

        XCTAssertEqual(prayerManager.otherPrayers.count, 3)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Asr")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Maghrib")
        XCTAssertEqual(prayerManager.otherPrayers[2].name, "Isha")
    }

    func testAsrPrayer() {
        fetch(at: (14,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Asr")

        XCTAssertEqual(prayerManager.otherPrayers.count, 2)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Maghrib")
        XCTAssertEqual(prayerManager.otherPrayers[1].name, "Isha")
    }

    func testMaghribPrayer() {
        fetch(at: (16,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Maghrib")

        XCTAssertEqual(prayerManager.otherPrayers.count, 1)
        XCTAssertEqual(prayerManager.otherPrayers[0].name, "Isha")
    }

    func testIshaPrayer() {
        fetch(at: (19,0))
        XCTAssertEqual(prayerManager.nextPrayer?.name, "Isha")
        XCTAssertTrue(prayerManager.otherPrayers.isEmpty)
    }
}

// MARK: - Helper methods
extension PrayerManagerTests {
    func fetch(at time: Time) {
        prayerManager.currentTimeMock = (time.hour!, time.minute!)
        let promise = XCTestExpectation(description: #function)
        DataProviderMock().prayerTimes(for: nil) { result, error in
            self.prayerManager.prayerDateTimes = result!.datetime
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
    }
}
