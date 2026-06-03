import AppKit
import SwiftUI

enum LTWidgetSpacing {
    static let xSmall: CGFloat = 2
    static let compact: CGFloat = 4
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xLarge: CGFloat = 16
}

enum LTWidgetTypography {
    static let title = Font.system(size: 15, weight: .bold, design: .default)
    static let compactTitle = Font.system(size: 12, weight: .bold, design: .default)
    static let user = Font.system(size: 16, weight: .semibold, design: .default)
    static let compactUser = Font.system(size: 13, weight: .semibold, design: .default)
    static let primaryNumber = Font.system(size: 40, weight: .black, design: .rounded)
    static let mediumNumber = Font.system(size: 48, weight: .black, design: .rounded)
    static let statNumber = Font.system(size: 20, weight: .bold, design: .rounded)
    static let compactStatNumber = Font.system(size: 17, weight: .bold, design: .rounded)
    static let label = Font.caption
    static let statLabel = Font.system(size: 14, weight: .medium, design: .default)
    static let compactStatLabel = Font.system(size: 11, weight: .medium, design: .default)
    static let stateTitle = Font.headline.weight(.semibold)
}

enum LTWidgetColor {
    static let cardBackground = LinearGradient(
        colors: [
            Color.adaptive(
                light: NSColor(red: 0.998, green: 0.998, blue: 0.993, alpha: 1),
                dark: NSColor(red: 0.078, green: 0.082, blue: 0.088, alpha: 1)
            ),
            Color.adaptive(
                light: NSColor(red: 0.992, green: 0.992, blue: 0.982, alpha: 1),
                dark: NSColor(red: 0.116, green: 0.120, blue: 0.130, alpha: 1)
            )
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let panel = Color.adaptive(
        light: NSColor(red: 0.986, green: 0.986, blue: 0.970, alpha: 0.74),
        dark: NSColor(red: 0.160, green: 0.166, blue: 0.176, alpha: 0.78)
    )
    static let panelStroke = Color.adaptive(
        light: NSColor(red: 0.10, green: 0.10, blue: 0.09, alpha: 0.16),
        dark: NSColor(red: 1.00, green: 1.00, blue: 0.94, alpha: 0.13)
    )
    static let primary = Color.adaptive(
        light: NSColor(red: 0.08, green: 0.08, blue: 0.075, alpha: 1),
        dark: NSColor(red: 0.940, green: 0.938, blue: 0.902, alpha: 1)
    )
    static let secondary = Color.adaptive(
        light: NSColor(red: 0.26, green: 0.26, blue: 0.24, alpha: 1),
        dark: NSColor(red: 0.780, green: 0.774, blue: 0.730, alpha: 1)
    )
    static let tertiary = Color.adaptive(
        light: NSColor(red: 0.42, green: 0.42, blue: 0.39, alpha: 1),
        dark: NSColor(red: 0.610, green: 0.604, blue: 0.560, alpha: 1)
    )
    static let brand = primary
    static let easy = Color(red: 0.30, green: 0.84, blue: 0.44)
    static let medium = Color(red: 1.00, green: 0.62, blue: 0.10)
    static let hard = Color(red: 1.00, green: 0.31, blue: 0.52)
    static let warning = primary
    static let error = primary
}

enum LTWidgetSizing {
    static let difficultyDot: CGFloat = 9
    static let compactDifficultyDot: CGFloat = 7
}

enum LTWidgetRadius {
    static let metric: CGFloat = 8
}

extension Color {
    static func adaptive(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .aqua])
            return match == .darkAqua ? dark : light
        })
    }
}
