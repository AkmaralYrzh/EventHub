import XCTest
@testable import EventHub

final class UserProfileTests: XCTestCase {

    func test_initials_takesFirstLettersOfTwoWords() {
        XCTAssertEqual(UserProfile.initials(from: "Акмарал Ержан"), "АЕ")
        XCTAssertEqual(UserProfile.initials(from: "dana"), "D")
        XCTAssertEqual(UserProfile.initials(from: "Иван Иванович Иванов"), "ИИ")
        XCTAssertEqual(UserProfile.initials(from: ""), "")
    }

    func test_initFromDict_parsesRoleAndFavorites() {
        let profile = UserProfile(from: [
            "uid": "u1", "firstName": "Дана", "lastName": "Ким",
            "email": "d@x.kz", "role": "organizer", "favoriteEventIds": ["e1"]
        ])

        XCTAssertEqual(profile?.role, .organizer)
        XCTAssertEqual(profile?.favoriteEventIds, ["e1"])
    }

    func test_initFromDict_unknownRole_returnsNil() {
        let profile = UserProfile(from: [
            "uid": "u1", "firstName": "Дана", "lastName": "Ким",
            "email": "d@x.kz", "role": "admin"
        ])

        XCTAssertNil(profile)
    }
}
