import Foundation

extension Date {

    /// «12 окт., 19:00» на языке интерфейса приложения.
    var eventHubFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        formatter.setLocalizedDateFormatFromTemplate("d MMM HH:mm")
        return formatter.string(from: self)
    }
}
