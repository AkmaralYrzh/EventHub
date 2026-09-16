import Foundation

extension UserDefaults {

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let userRole = "userRole"
        static let userName = "userName"
        static let forceDarkTheme = "forceDarkTheme"
        static let notificationsEnabled = "notificationsEnabled"
    }

    var hasSeenOnboarding: Bool {
        get { bool(forKey: Keys.hasSeenOnboarding) }
        set { set(newValue, forKey: Keys.hasSeenOnboarding) }
    }

    var userRole: UserRole? {
        get {
            guard let raw = string(forKey: Keys.userRole) else { return nil }
            return UserRole(rawValue: raw)
        }
        set { set(newValue?.rawValue, forKey: Keys.userRole) }
    }

    var userName: String? {
        get { string(forKey: Keys.userName) }
        set { set(newValue, forKey: Keys.userName) }
    }

    var forceDarkTheme: Bool {
        get { bool(forKey: Keys.forceDarkTheme) }
        set { set(newValue, forKey: Keys.forceDarkTheme) }
    }

    var notificationsEnabled: Bool {
        get { bool(forKey: Keys.notificationsEnabled) }
        set { set(newValue, forKey: Keys.notificationsEnabled) }
    }
}
