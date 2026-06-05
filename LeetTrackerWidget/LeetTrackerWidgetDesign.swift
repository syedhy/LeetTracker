import AppKit
import SwiftUI

enum LTWidgetSpacing {
    static let xSmall: CGFloat = 2
    static let compact: CGFloat = 4
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xLarge: CGFloat = 16
    static let xxLarge: CGFloat = 20
    static let smallPadding: CGFloat = 16
    static let mediumPadding: CGFloat = 20
}

enum LTWidgetTypography {
    static let eyebrow = Font.system(size: 10, weight: .black, design: .rounded)
    static let compactTitle = Font.system(size: 13, weight: .black, design: .rounded)
    static let title = Font.system(size: 16, weight: .black, design: .rounded)
    static let display = Font.system(size: 44, weight: .black, design: .rounded)
    static let mediumDisplay = Font.system(size: 56, weight: .black, design: .rounded)
    static let user = Font.system(size: 18, weight: .black, design: .rounded)
    static let compactUser = Font.system(size: 15, weight: .black, design: .rounded)
    static let headline = Font.system(size: 18, weight: .black, design: .rounded)
    static let compactHeadline = Font.system(size: 16, weight: .black, design: .rounded)
    static let metricNumber = Font.system(size: 24, weight: .black, design: .rounded)
    static let compactMetricNumber = Font.system(size: 16, weight: .black, design: .rounded)
    static let label = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let compactLabel = Font.system(size: 10, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 13, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 11, weight: .semibold, design: .rounded)
    static let stateTitle = Font.system(size: 17, weight: .black, design: .rounded)
}

enum LTWidgetColor {
    static let cardBackground = LinearGradient(
        colors: [
            Color.adaptive(
                light: NSColor(red: 0.999, green: 0.998, blue: 0.988, alpha: 1),
                dark: NSColor(red: 0.095, green: 0.098, blue: 0.104, alpha: 1)
            ),
            Color.adaptive(
                light: NSColor(red: 0.984, green: 0.982, blue: 0.966, alpha: 1),
                dark: NSColor(red: 0.150, green: 0.154, blue: 0.164, alpha: 1)
            )
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let panel = Color.adaptive(
        light: NSColor(red: 1.000, green: 0.998, blue: 0.982, alpha: 0.82),
        dark: NSColor(red: 0.190, green: 0.194, blue: 0.204, alpha: 0.82)
    )
    static let tintedPanel = Color.adaptive(
        light: NSColor(red: 0.998, green: 0.996, blue: 0.980, alpha: 0.58),
        dark: NSColor(red: 0.130, green: 0.134, blue: 0.144, alpha: 0.62)
    )
    static let panelStroke = Color.adaptive(
        light: NSColor(red: 0.08, green: 0.08, blue: 0.072, alpha: 0.22),
        dark: NSColor(red: 1.00, green: 0.98, blue: 0.90, alpha: 0.18)
    )
    static let sketch = Color.adaptive(
        light: NSColor(red: 0.06, green: 0.06, blue: 0.055, alpha: 1),
        dark: NSColor(red: 0.96, green: 0.94, blue: 0.86, alpha: 1)
    )
    static let primary = Color.adaptive(
        light: NSColor(red: 0.075, green: 0.075, blue: 0.070, alpha: 1),
        dark: NSColor(red: 0.955, green: 0.950, blue: 0.900, alpha: 1)
    )
    static let secondary = Color.adaptive(
        light: NSColor(red: 0.300, green: 0.295, blue: 0.270, alpha: 1),
        dark: NSColor(red: 0.780, green: 0.765, blue: 0.700, alpha: 1)
    )
    static let tertiary = Color.adaptive(
        light: NSColor(red: 0.470, green: 0.462, blue: 0.430, alpha: 1),
        dark: NSColor(red: 0.640, green: 0.625, blue: 0.570, alpha: 1)
    )
    static let paperLine = Color.adaptive(
        light: NSColor(red: 0.12, green: 0.12, blue: 0.10, alpha: 0.07),
        dark: NSColor(red: 1.00, green: 0.96, blue: 0.86, alpha: 0.045)
    )
    static let brand = primary
    static let easy = Color(red: 0.25, green: 0.78, blue: 0.43)
    static let medium = Color(red: 1.00, green: 0.60, blue: 0.08)
    static let hard = Color(red: 0.96, green: 0.26, blue: 0.48)
    static let warning = medium
    static let error = hard
}

enum LTWidgetSizing {
    static let dot: CGFloat = 8
    static let compactDot: CGFloat = 7
    static let tinyDot: CGFloat = 5
    static let brandIcon: CGFloat = 28
    static let smallBrandIcon: CGFloat = 22
}

enum LTWidgetRadius {
    static let panel: CGFloat = 18
    static let miniPanel: CGFloat = 12
    static let badge: CGFloat = 10
}

extension Color {
    static func adaptive(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .aqua])
            return match == .darkAqua ? dark : light
        })
    }
}
