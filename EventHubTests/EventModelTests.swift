import XCTest
@testable import EventHub

final class EventModelTests: XCTestCase {

    private let validDict: [String: Any] = [
        "title": "Концерт",
        "description": "Описание",
        "startDate": 1_800_000_000.0,
        "location": "Almaty Arena",
        "city": "almaty",
        "organizerId": "org-1",
        "organizerName": "Дана",
        "category": "music",
        "price": "5000",
        "isFree": false,
        "coverImageName": "c2",
        "participantIds": ["u1", "u2"]
    ]

    func test_initFromDict_parsesAllFields() {
        let event = EventModel(id: "e1", from: validDict)

        XCTAssertNotNil(event)
        XCTAssertEqual(event?.id, "e1")
        XCTAssertEqual(event?.title, "Концерт")
        XCTAssertEqual(event?.startDate, Date(timeIntervalSince1970: 1_800_000_000))
        XCTAssertEqual(event?.city, "almaty")
        XCTAssertEqual(event?.participantIds, ["u1", "u2"])
    }

    func test_initFromDict_missingRequiredField_returnsNil() {
        var dict = validDict
        dict.removeValue(forKey: "title")

        XCTAssertNil(EventModel(id: "e1", from: dict))
    }

    func test_initFromDict_missingOptionalFields_usesDefaults() {
        var dict = validDict
        dict.removeValue(forKey: "city")
        dict.removeValue(forKey: "participantIds")

        let event = EventModel(id: "e1", from: dict)

        XCTAssertEqual(event?.city, "almaty")
        XCTAssertEqual(event?.participantIds, [])
    }

    func test_dictionary_roundTrip() {
        let original = EventModel(id: "e1", from: validDict)!

        let restored = EventModel(id: "e1", from: original.dictionary)

        XCTAssertEqual(restored, original)
    }

    func test_isJoined() {
        let event = EventModel(id: "e1", from: validDict)!

        XCTAssertTrue(event.isJoined(by: "u1"))
        XCTAssertFalse(event.isJoined(by: "u9"))
        XCTAssertFalse(event.isJoined(by: nil))
    }

    func test_withParticipation_addsAndRemovesWithoutDuplicates() {
        let event = EventModel(id: "e1", from: validDict)!

        let joined = event.withParticipation(uid: "u3", isJoined: true)
        let joinedTwice = joined.withParticipation(uid: "u3", isJoined: true)
        let left = joinedTwice.withParticipation(uid: "u1", isJoined: false)

        XCTAssertEqual(joined.participantsCount, 3)
        XCTAssertEqual(joinedTwice.participantsCount, 3)
        XCTAssertEqual(left.participantIds, ["u2", "u3"])
    }

    func test_isUpcoming() {
        let event = EventModel(id: "e1", from: validDict)!
        let before = event.startDate.addingTimeInterval(-60)
        let after = event.startDate.addingTimeInterval(60)

        XCTAssertTrue(event.isUpcoming(now: before))
        XCTAssertFalse(event.isUpcoming(now: after))
    }
}
