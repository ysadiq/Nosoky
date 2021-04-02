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

    func testInitViewModel() {
        let promise = XCTestExpectation(description: #file)
        promise.expectedFulfillmentCount = 2

        XCTAssertEqual(viewController.prayerNameLabel.text!, "--")
        XCTAssertEqual(viewController.lastUpdatedDateLabel.text!, "-- ----")
        XCTAssertEqual(viewController.lastThirdNightTimeLabel.text!, "--:--")

        let updateLoadingStatus = { [weak self] in
            promise.fulfill()
        }

        viewController.viewModel.updateLoadingStatus.append(updateLoadingStatus)
        viewController.initViewModel(with: CLLocationCoordinate2D(latitude: 30.086594, longitude: 31.344536))

        wait(for: [promise], timeout: 0.5)

        let nextPrayer = viewController.prayerManager.nextPrayer
        XCTAssertEqual(viewController.prayerNameLabel.text!, nextPrayer!.name)

        let timeRemaining =  viewController.prayerManager.timeRemainingTo(nextPrayer!.time)!.time
        let expectedPrayerTimeText = timeRemaining.hour == 0 ? "\((timeRemaining.minute)!)" : "\((timeRemaining.hour)!):\((timeRemaining.minute)!)"

        XCTAssertEqual(viewController.prayerTimeLabel.text!, expectedPrayerTimeText)
        XCTAssertEqual(viewController.lastUpdatedDateLabel.text!, DateHelper.string(dateFormat: "MMMM yyyy"))
        XCTAssertEqual(viewController.lastThirdNightTimeLabel.text!, "1:7")
        XCTAssertEqual(viewController.otherPrayersCollectionView.numberOfItems(inSection: 0), 4)
    }
}
