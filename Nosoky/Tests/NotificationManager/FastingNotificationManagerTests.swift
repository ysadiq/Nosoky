//
//  FastingNotificationManagerTests.swift
//  NosokyTests
//
//  Created by Yahya Saddiq on 4/3/21.
//

import XCTest
import NotificationCenter

@testable import Nosoky

class FastingNotificationManagerTests: XCTestCase {
    var notificationManager: NotificationManagerMock!
    var notificationCenter: UserNotificationCenterMock!

    override func setUp() {
        super.setUp()

        notificationCenter = UserNotificationCenterMock()

        notificationManager = NotificationManagerMock(userNotificationCenter: notificationCenter)
        notificationManager.delegate = FastingManager.shared
        notificationManager.addNotificationFromDate = DateHelper.date(from: "2021-04-01")!
    }

    override func tearDown() {
        notificationManager = nil
        notificationCenter = nil

        super.tearDown()
    }

    func testWeeklyNotificationsBetweenShaabanAndRamadaan() {
        let expectation = XCTestExpectation(description: "fetch Hijri dates")
        DataProviderMock().prayerTimes { result, _ in
            FastingManager.shared.dates = result!.datetime.map { $0.date }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        notificationManager.addNotificationExpectation.expectedFulfillmentCount = 4
        notificationCenter.grantAuthorization = true
        notificationManager.addNotificationsIfNeeded()
        wait(for: [notificationManager.addNotificationExpectation], timeout: 1)
        XCTAssertEqual(notificationManager.numberOfAddedNotifications, 4)

        XCTAssertEqual(notificationCenter.requests.count, 4)
        XCTAssertEqual(notificationCenter.requests[0].content.title, "Thursday Fasting")
        XCTAssertEqual(notificationCenter.requests[0].content.body, "")
        var notificationDate = (notificationCenter.requests[0].trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 12)
        XCTAssertEqual(notificationDate?.minute, 0)
        XCTAssertEqual(notificationDate?.day, 1)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)

        XCTAssertEqual(notificationCenter.requests[3].content.title, "Monday Fasting")
        XCTAssertEqual(notificationCenter.requests[3].content.body, "")
        notificationDate = (notificationCenter.requests[3].trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(notificationDate?.hour, 12)
        XCTAssertEqual(notificationDate?.minute, 0)
        XCTAssertEqual(notificationDate?.day, 12)
        XCTAssertEqual(notificationDate?.month, 4)
        XCTAssertEqual(notificationDate?.year, 2021)
    }
}
