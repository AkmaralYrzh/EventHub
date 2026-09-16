import Foundation

/// Ошибки авторизации, понятные пользователю.
/// Сервис переводит коды Firebase в эти случаи, чтобы экраны не знали про Firebase.
enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case userDisabled
    case tooManyRequests
    case network
    case profileNotFound
    case unknown

    /// Ключ локализации — один на случай, чтобы текст менялся вместе с языком приложения.
    var localizationKey: String {
        switch self {
        case .invalidEmail:      return "auth_error_invalid_email"
        case .wrongPassword:     return "auth_error_wrong_password"
        case .userNotFound:      return "auth_error_user_not_found"
        case .emailAlreadyInUse: return "auth_error_email_in_use"
        case .weakPassword:      return "auth_error_weak_password"
        case .userDisabled:      return "auth_error_user_disabled"
        case .tooManyRequests:   return "auth_error_too_many_requests"
        case .network:           return "auth_error_network"
        case .profileNotFound:   return "auth_error_profile_not_found"
        case .unknown:           return "auth_error_unknown"
        }
    }

    var errorDescription: String? { L(localizationKey) }
}
