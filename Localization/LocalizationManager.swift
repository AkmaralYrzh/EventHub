import Foundation

final class LocalizationManager {
    static let shared = LocalizationManager()

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
    }

    private(set) var currentLanguage: String

    private init() {
        currentLanguage = UserDefaults.standard.string(forKey: Keys.selectedLanguage) ?? "ru"
    }

    func setLanguage(_ code: String) {
        currentLanguage = code
        UserDefaults.standard.set(code, forKey: Keys.selectedLanguage)
    }

    func localizedString(_ key: String) -> String {
        guard
            let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return key
        }
        return NSLocalizedString(key, bundle: bundle, value: key, comment: "")
    }
}

func L(_ key: String) -> String {
    LocalizationManager.shared.localizedString(key)
}
