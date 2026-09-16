import XCTest
@testable import EventHub

final class ListStateTests: XCTestCase {

    func test_from_emptyArray_isEmptyWithMessage() {
        XCTAssertEqual(ListState.from([Int](), emptyMessage: "пусто"), .empty(message: "пусто"))
    }

    func test_from_nonEmptyArray_isLoaded() {
        XCTAssertEqual(ListState.from([1], emptyMessage: "пусто"), .loaded)
    }

    func test_authError_hasUniqueLocalizationKeys() {
        let errors: [AuthError] = [.invalidEmail, .wrongPassword, .userNotFound, .emailAlreadyInUse,
                                   .weakPassword, .userDisabled, .tooManyRequests, .network,
                                   .profileNotFound, .requiresRecentLogin, .unknown]
        let keys = Set(errors.map(\.localizationKey))

        XCTAssertEqual(keys.count, errors.count)
        XCTAssertTrue(keys.allSatisfy { $0.hasPrefix("auth_error_") })
    }
}
