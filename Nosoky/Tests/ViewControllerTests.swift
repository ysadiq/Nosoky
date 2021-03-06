//
//  ViewControllerTests.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 3/22/21.
//

import XCTest
import CoreLocation
@testable import Nosoky

class ViewControllerTests: XCTestCase {
    var viewController: ViewController!
    var prayerManagerMock: PrayerManagerMock!

    override func setUp() {
        super.setUp()

        prayerManagerMock = PrayerManagerMock()
        prayerManagerMock.todayAsString = "2021-04-02"
        prayerManagerMock.tomorrowAsString = "2021-04-03"
        
        let viewController = ViewController.instance(
            from: "Main",
            with: "ViewController",
            bundle: nil)

        guard let mainViewController = viewController as? ViewController else {
            return
        }

        self.viewController = mainViewController
        self.viewController.prayerManager = prayerManagerMock
        self.viewController.viewModel = ViewModel(
            dataProvider: DataProviderMock(),
            prayerManager: self.viewController.prayerManager
        )
        self.viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        
        super.tearDown()
    }

    func testLoadingUIStatus() {
        XCTAssertEqual(viewController.nextPrayerTitleLabel.text!, "Next Prayer")
        XCTAssertEqual(viewController.prayerNameLabel.text!, "--")
        XCTAssertEqual(viewController.prayerTimeLabel.text!, "--:--")
        XCTAssertTrue(viewController.prayerTimeUnitLabel.isHidden)
        XCTAssertEqual(viewController.otherPrayersCollectionView.numberOfItems(inSection: 0), 0)
        XCTAssertEqual(viewController.lastThirdNightTimeLabel.text!, "--:--")
        XCTAssertEqual(viewController.lastUpdatedLabel.text!, "Last updated")
        XCTAssertEqual(viewController.lastUpdatedDateLabel.text!, "-- ----")
    }

    func testPopulatedUIStatus() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2
        prayerManagerMock.currentTimeMock = Time(hour: 2, minute: 0)

        let updateLoadingStatus = {
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel()

        wait(for: [promise], timeout: 1)

        XCTAssertEqual(viewController.nextPrayerTitleLabel.text!, "Next Prayer")
        XCTAssertEqual(viewController.prayerNameLabel.text!, "Fajr")
        XCTAssertEqual(viewController.prayerTimeLabel.text!, "2:22")
        XCTAssertTrue(viewController.prayerTimeUnitLabel.isHidden)
        XCTAssertEqual(viewController.otherPrayersCollectionView.numberOfItems(inSection: 0), 4)
        XCTAssertEqual(viewController.lastThirdNightTimeLabel.text!, "1:7")
        XCTAssertEqual(viewController.lastUpdatedLabel.text!, "Last updated")
        XCTAssertEqual(viewController.lastUpdatedDateLabel.text!, "March 2021")
        XCTAssertEqual((viewController.collectionView(viewController.otherPrayersCollectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! PrayerCollectionViewCell).name.text, "Jumuah")
    }

    func testPopulatedUIStatusWithMinutesTimeRemaining() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2

        prayerManagerMock.currentTimeMock = Time(hour: 4, minute: 0)

        let updateLoadingStatus = {
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel()

        wait(for: [promise], timeout: 0.2)
        XCTAssertFalse(viewController.prayerTimeUnitLabel.isHidden)
        XCTAssertEqual(viewController.prayerTimeLabel.text, "22")
    }

    func testLastThirdNightViewPreHours() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2

        prayerManagerMock.currentTimeMock = Time(hour: 23, minute: 0)

        let updateLoadingStatus = {
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel()

        wait(for: [promise], timeout: 0.1)
        XCTAssertEqual(viewController.nextPrayerTitleLabel.text!, "The last third of the night starts in")
        XCTAssertEqual(viewController.prayerTimeLabel.text!, "1:59")
        XCTAssertTrue(viewController.prayerNameLabel.isHidden)
        XCTAssertTrue(viewController.lastThirdNightStackView.isHidden)
    }

    func testLastThirdNightViewPreMinutes() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2

        prayerManagerMock.currentTimeMock = Time(hour: 0, minute: 59)

        let updateLoadingStatus = {
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel()

        wait(for: [promise], timeout: 0.1)
        XCTAssertEqual(viewController.nextPrayerTitleLabel.text!, "The last third of the night starts in")
        XCTAssertEqual(viewController.prayerTimeLabel.text!, "1")
        XCTAssertTrue(viewController.prayerNameLabel.isHidden)
        XCTAssertTrue(viewController.lastThirdNightStackView.isHidden)
    }

    func testNextPrayerOnTimeChange() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2

        let updateLoadingStatus = {
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel()

        wait(for: [promise], timeout: 1)
        prayerManagerMock.currentTimeMock = Time(hour: 11, minute: 0)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.prayerNameLabel.text, "Jumuah")

        prayerManagerMock.currentTimeMock = Time(hour: 14, minute: 0)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.prayerNameLabel.text, "Asr")

        prayerManagerMock.currentTimeMock = Time(hour: 16, minute: 0)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.prayerNameLabel.text, "Maghrib")

        prayerManagerMock.currentTimeMock = Time(hour: 18, minute: 40)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.prayerNameLabel.text, "Isha")

        prayerManagerMock.currentTimeMock = Time(hour: 20, minute: 0)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.nextPrayerTitleLabel.text, "The last third of the night starts in")
        XCTAssertTrue(viewController.prayerNameLabel.isHidden)
        XCTAssertTrue(viewController.lastThirdNightStackView.isHidden)

        prayerManagerMock.currentTimeMock = Time(hour: 0, minute: 24)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.nextPrayerTitleLabel.text, "The last third of the night starts in")
        XCTAssertTrue(viewController.prayerNameLabel.isHidden)
        XCTAssertTrue(viewController.lastThirdNightStackView.isHidden)

        prayerManagerMock.currentTimeMock = Time(hour: 1, minute: 24)
        prayerManagerMock.onMinuteUpdate?()
        XCTAssertEqual(viewController.prayerNameLabel.text, "Fajr")
    }
}
