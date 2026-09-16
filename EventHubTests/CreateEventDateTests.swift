import XCTest
@testable import EventHub

final class CreateEventDateTests: XCTestCase {

    func test_defaultStartDate_isOneHourAhead() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertEqual(CreateEventViewModel.defaultStartDate(now: now), now.addingTimeInterval(3600))
    }

    func test_isValidStartDate_onlyFutureDatesAreValid() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertTrue(CreateEventViewModel.isValidStartDate(now.addingTimeInterval(1), now: now))
        XCTAssertFalse(CreateEventViewModel.isValidStartDate(now, now: now))
        XCTAssertFalse(CreateEventViewModel.isValidStartDate(now.addingTimeInterval(-1), now: now))
    }
}
