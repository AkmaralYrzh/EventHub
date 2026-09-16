import XCTest
@testable import EventHub

final class UserHomeFilterTests: XCTestCase {

    private func event(_ id: String, category: String, city: String) -> EventModel {
        EventModel(id: id, title: id, description: "", startDate: Date(), location: "",
                   city: city, organizerId: "o", organizerName: "o", category: category,
                   price: "", isFree: true, coverImageName: "c1")
    }

    private lazy var events = [
        event("1", category: "music", city: "almaty"),
        event("2", category: "sport", city: "almaty"),
        event("3", category: "music", city: "astana")
    ]

    func test_filter_all_returnsEverything() {
        let result = UserHomeViewModel.filter(events, categoryId: "all", cityId: "all")
        XCTAssertEqual(result.map(\.id), ["1", "2", "3"])
    }

    func test_filter_byCategory() {
        let result = UserHomeViewModel.filter(events, categoryId: "music", cityId: "all")
        XCTAssertEqual(result.map(\.id), ["1", "3"])
    }

    func test_filter_byCategoryAndCity() {
        let result = UserHomeViewModel.filter(events, categoryId: "music", cityId: "astana")
        XCTAssertEqual(result.map(\.id), ["3"])
    }

    func test_filter_noMatches_returnsEmpty() {
        let result = UserHomeViewModel.filter(events, categoryId: "food", cityId: "all")
        XCTAssertTrue(result.isEmpty)
    }
}
