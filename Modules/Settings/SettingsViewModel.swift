import Foundation
import Combine
import UserNotifications

final class SettingsViewModel {

    static let supportEmail = "support@eventhub.kz"
    static let languages: [(code: String, titleKey: String)] = [
        ("ru", "language_ru"),
        ("en", "language_en"),
        ("kk", "language_kk")
    ]

    // MARK: - Выходные данные
    @Published private(set) var isDarkThemeOn: Bool = UserDefaults.standard.forceDarkTheme
    @Published private(set) var notificationsEnabled: Bool = UserDefaults.standard.notificationsEnabled
    @Published private(set) var isBusy: Bool = false

    var currentLanguageCode: String { LocalizationManager.shared.currentLanguage }
    var currentLanguageTitle: String {
        let key = Self.languages.first { $0.code == currentLanguageCode }?.titleKey ?? "language_ru"
        return L(key)
    }
    var userEmail: String? { authService.currentUser?.email }

    // MARK: - Внутреннее
    private let authService = AuthService()
    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Тема и язык

    func setDarkTheme(_ isOn: Bool) {
        isDarkThemeOn = isOn
        UserDefaults.standard.forceDarkTheme = isOn
    }

    func setLanguage(_ code: String) {
        LocalizationManager.shared.setLanguage(code)
    }

    // MARK: - Уведомления

    /// Включение запрашивает системное разрешение; если пользователь отказал — переключатель возвращается.
    func setNotifications(_ isOn: Bool) -> AnyPublisher<Bool, Never> {
        guard isOn else {
            notificationsEnabled = false
            UserDefaults.standard.notificationsEnabled = false
            return Just(false).eraseToAnyPublisher()
        }

        let center = notificationCenter
        return Deferred {
            Future { promise in
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    promise(.success(granted))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { [weak self] granted in
            self?.notificationsEnabled = granted
            UserDefaults.standard.notificationsEnabled = granted
        })
        .eraseToAnyPublisher()
    }

    // MARK: - Аккаунт

    func sendPasswordReset() -> AnyPublisher<Void, Error> {
        guard let email = userEmail else {
            return Fail(error: AuthError.userNotFound).eraseToAnyPublisher()
        }
        return withBusy(authService.sendPasswordReset(email: email))
    }

    func deleteAccount() -> AnyPublisher<Void, Error> {
        withBusy(authService.deleteAccount())
            .handleEvents(receiveOutput: { _ in
                UserDefaults.standard.userRole = nil
                UserDefaults.standard.userName = nil
            })
            .eraseToAnyPublisher()
    }

    private func withBusy<T>(_ publisher: AnyPublisher<T, Error>) -> AnyPublisher<T, Error> {
        isBusy = true
        return publisher
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveCompletion: { [weak self] _ in self?.isBusy = false },
                receiveCancel: { [weak self] in self?.isBusy = false }
            )
            .eraseToAnyPublisher()
    }
}
