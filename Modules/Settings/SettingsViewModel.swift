import Foundation

class SettingsViewModel {

    private(set) var isDarkThemeOn: Bool = UserDefaults.standard.forceDarkTheme

    func setDarkTheme(_ isOn: Bool) {
        isDarkThemeOn = isOn
        UserDefaults.standard.forceDarkTheme = isOn
    }
}
