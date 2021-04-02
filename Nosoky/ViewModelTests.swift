//
//  ViewModelTests.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/2/21.
//

import XCTest
@testable import Nosoky

class ViewModelTests: XCTestCase {
    var viewModel: ViewModel!

    override func setUp() {
        super.setUp()

        viewModel = ViewModel(
            dataProvider: DataProviderMock(),
            prayerManager: PrayerManagerMock()
        )
    }

    override func tearDown() {
        viewModel = nil

        super.tearDown()
    }

    func testMultipleListeners() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2

        let listenerOne = {
            promise.fulfill()
        }
        let listenerTwo = {
            promise.fulfill()
        }

        viewModel.updateLoadingStatus = [listenerOne, listenerTwo]
        viewModel.contentState = .populated

        wait(for: [promise], timeout: 0.1)
    }

    func testMultipleListenersInOrder() {
        let promiseOne = XCTestExpectation(description: #function)
        let promiseTwo = XCTestExpectation(description: #function)

        let listenerOne = {
            promiseOne.fulfill()
        }

        let listenerTwo = {
            promiseTwo.fulfill()
        }

        viewModel.updateLoadingStatus = [listenerOne, listenerTwo]
        viewModel.contentState = .populated

        wait(for: [promiseOne, promiseTwo], timeout: 0.1, enforceOrder: true)
    }

    func testContentStates() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2
        viewModel.updateLoadingStatus = [{
            promise.fulfill()
        }]

        XCTAssertEqual(viewModel.contentState, .empty)

        viewModel.fetchData()

        XCTAssertEqual(viewModel.contentState, .loading)

        wait(for: [promise], timeout: 0.2)

        XCTAssertEqual(viewModel.contentState, .populated)
    }

    func testLastUpdated() {
        let promise = XCTestExpectation(description: #function)
        promise.expectedFulfillmentCount = 2
        viewModel.updateLoadingStatus = [{
            promise.fulfill()
        }]

        viewModel.fetchData()
        wait(for: [promise], timeout: 0.2)

        XCTAssertEqual(viewModel.lastUpdated, "March 2021")
    }
}
