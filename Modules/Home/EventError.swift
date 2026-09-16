import Foundation

/// Ошибки мероприятий, понятные пользователю.
enum EventError: LocalizedError, Equatable {
    case full
    case notFound

    var localizationKey: String {
        switch self {
        case .full:     return "event_error_full"
        case .notFound: return "event_error_not_found"
        }
    }

    var errorDescription: String? { L(localizationKey) }

    /// Firestore возвращает ошибку транзакции как NSError — сверяем по домену и коду.
    func matches(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == (self as NSError).domain && nsError.code == (self as NSError).code
    }
}
