import XCTest
@testable import EventHub

final class UserHomeFilterTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_000_000)

    private func event(_ id: String, category: String, city: String, offset: TimeInterval = 3600) -> EventModel {
        EventModel(id: id, title: id, description: "", startDate: now.addingTimeInterval(offset), location: "",
                   city: city, organizerId: "o", organizerName: "o", category: category,
                   price: "", isFree: true, coverImageName: "c1")
    }

    private lazy var events = [
        event("1", category: "music", city: "almaty"),
        event("2", category: "sport", city: "almaty"),
        event("3", category: "music", city: "astana"),
        event("4", category: "music", city: "almaty", offset: -3600)   // уже прошло
    ]

    func test_filter_all_returnsEverything() {
        let result = UserHomeViewModel.filter(events, categoryId: "all", cityId: "all", now: now)
        XCTAssertEqual(result.map(\.id), ["1", "2", "3"])
    }

    func test_filter_byCategory() {
        let result = UserHomeViewModel.filter(events, categoryId: "music", cityId: "all", now: now)
        XCTAssertEqual(result.map(\.id), ["1", "3"])
    }

    func test_filter_byCategoryAndCity() {
        let result = UserHomeViewModel.filter(events, categoryId: "music", cityId: "astana", now: now)
        XCTAssertEqual(result.map(\.id), ["3"])
    }

    func test_filter_noMatches_returnsEmpty() {
        let result = UserHomeViewModel.filter(events, categoryId: "food", cityId: "all", now: now)
        XCTAssertTrue(result.isEmpty)
    }

    func test_filter_hidesPastEvents() {
        let result = UserHomeViewModel.filter(events, categoryId: "music", cityId: "almaty", now: now)
        XCTAssertEqual(result.map(\.id), ["1"])
    }
}
