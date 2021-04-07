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
    let coordinate = CLLocationCoordinate2D(latitude: 30.086594, longitude: 31.344536)

    override func setUp() {
        super.setUp()

        prayerManagerMock = PrayerManagerMock()
        prayerManagerMock.todayAsString = "2021-04-02"
        
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
        XCTAssertEqual(viewController.prayerTimeLabel.text!, "2:7")
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
        XCTAssertEqual(viewController.prayerTimeLabel.text!, "8")
        XCTAssertTrue(viewController.prayerNameLabel.isHidden)
        XCTAssertTrue(viewController.lastThirdNightStackView.isHidden)
    }
}
