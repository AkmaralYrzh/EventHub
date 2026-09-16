import UIKit

extension UIColor {
    static var eventHubBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.18, green: 0.12, blue: 0.11, alpha: 1.0)
                : UIColor(red: 0.97, green: 0.95, blue: 0.90, alpha: 1.0)
        }
    }

    static var eventHubTextPrimary: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1.0)
                : UIColor(red: 0.18, green: 0.12, blue: 0.11, alpha: 1.0)
        }
    }

    static var eventHubOnAccent: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.09, blue: 0.08, alpha: 1.0)
                : .white
        }
    }

    static var eventHubAccent: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.66, green: 0.51, blue: 0.42, alpha: 1.0)
                : UIColor(red: 0.18, green: 0.12, blue: 0.11, alpha: 1.0)
        }
    }

    static var eventHubSecondary: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 0.6)
                : UIColor(red: 0.37, green: 0.29, blue: 0.26, alpha: 0.8)
        }
    }

    static var eventHubMuted: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.24, green: 0.17, blue: 0.14, alpha: 1.0)
                : UIColor(red: 0.90, green: 0.85, blue: 0.77, alpha: 1.0)
        }
    }

    static var eventHubError: UIColor {
        UIColor(red: 0.80, green: 0.25, blue: 0.25, alpha: 1.0)
    }

    static var eventHubGlassFill: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.06)
                : UIColor.white.withAlphaComponent(0.55)
        }
    }

    static var eventHubGlassBorder: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.12)
                : UIColor.black.withAlphaComponent(0.08)
        }
    }

    // MARK: - Фиксированные цвета (не зависят от темы)

    /// Тёмный «ореховый» фон — онбординг и обложки всегда тёмные, независимо от темы.
    static let eventHubWalnut = UIColor(red: 0.18, green: 0.12, blue: 0.11, alpha: 1.0)
    static let eventHubWalnutGradient: [UIColor] = [
        UIColor(red: 0.49, green: 0.40, blue: 0.35, alpha: 1.0),
        UIColor(red: 0.37, green: 0.29, blue: 0.26, alpha: 1.0),
        eventHubWalnut
    ]
    static let eventHubCream = UIColor(red: 0.94, green: 0.90, blue: 0.85, alpha: 1.0)
    static let eventHubOnDarkText = UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1.0)
    static let eventHubOnDarkSecondary = UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 0.6)

    /// Пять пар цветов для градиентных обложек мероприятий.
    static let eventHubCoverGradients: [[UIColor]] = [
        [UIColor(red: 0.85, green: 0.77, blue: 0.63, alpha: 1), UIColor(red: 0.23, green: 0.16, blue: 0.09, alpha: 1)],
        [UIColor(red: 0.95, green: 0.65, blue: 0.35, alpha: 1), UIColor(red: 0.76, green: 0.34, blue: 0.23, alpha: 1)],
        [UIColor(red: 0.88, green: 0.48, blue: 0.37, alpha: 1), UIColor(red: 0.51, green: 0.35, blue: 0.56, alpha: 1)],
        [UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1), UIColor(red: 0.75, green: 0.51, blue: 0.53, alpha: 1)],
        [UIColor(red: 1.00, green: 0.84, blue: 0.65, alpha: 1), UIColor(red: 0.98, green: 0.55, blue: 0.14, alpha: 1)]
    ]

    /// Бейдж роли в профиле.
    static let eventHubRoleOrganizerBackground = UIColor(red: 0.66, green: 0.55, blue: 0.98, alpha: 1)
    static let eventHubRoleOrganizerText = UIColor(red: 0.11, green: 0.07, blue: 0.20, alpha: 1)
    static let eventHubRoleUserBackground = UIColor(red: 0.50, green: 0.78, blue: 0.66, alpha: 1)
    static let eventHubRoleUserText = UIColor(red: 0.05, green: 0.14, blue: 0.09, alpha: 1)
}
