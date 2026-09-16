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
}
