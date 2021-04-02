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

    override func setUp() {
        super.setUp()

        let viewController = ViewController.instance(
            from: "Main",
            with: "ViewController",
            bundle: nil)

        guard let mainViewController = viewController as? ViewController else {
            return
        }

        self.viewController = mainViewController
        self.viewController.locationManager = nil
        self.viewController.prayerManager = PrayerManagerMock()
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
        let promise = XCTestExpectation(description: #file)
        promise.expectedFulfillmentCount = 2

        let updateLoadingStatus = { [weak self] in
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel(with: CLLocationCoordinate2D(latitude: 30.086594, longitude: 31.344536))

        wait(for: [promise], timeout: 0.5)

        let nextPrayer = viewController.prayerManager.nextPrayer
        let timeRemaining =  viewController.prayerManager.timeRemainingTo(nextPrayer!.time)!.time
        let expectedPrayerTimeText = timeRemaining.hour == 0 ? "\((timeRemaining.minute)!)" : "\((timeRemaining.hour)!):\((timeRemaining.minute)!)"

        XCTAssertEqual(viewController.nextPrayerTitleLabel.text!, "Next Prayer")
        XCTAssertEqual(viewController.prayerNameLabel.text!, "Fajr")
        XCTAssertEqual(viewController.prayerNameLabel.text!, nextPrayer!.name)
        XCTAssertEqual(viewController.prayerTimeLabel.text!, expectedPrayerTimeText)
        XCTAssertTrue(viewController.prayerTimeUnitLabel.isHidden)
        XCTAssertEqual(viewController.otherPrayersCollectionView.numberOfItems(inSection: 0), 4)
        XCTAssertEqual(viewController.lastThirdNightTimeLabel.text!, "1:7")
        XCTAssertEqual(viewController.lastUpdatedLabel.text!, "Last updated")
        XCTAssertEqual(viewController.lastUpdatedDateLabel.text!, DateHelper.string(dateFormat: "MMMM yyyy"))
//        XCTAssertEqual((viewController.otherPrayersCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! PrayerCollectionViewCell).name.text, "Dhuhur")
    }
}
