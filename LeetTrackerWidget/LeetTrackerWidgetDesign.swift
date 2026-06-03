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
    static let title = Font.system(size: 14, weight: .bold, design: .default)
    static let compactTitle = Font.system(size: 10, weight: .bold, design: .default)
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
            Color(red: 0.998, green: 0.998, blue: 0.990),
            Color(red: 0.990, green: 0.990, blue: 0.978)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let panel = Color(red: 0.985, green: 0.985, blue: 0.965).opacity(0.72)
    static let panelStroke = Color(red: 0.10, green: 0.10, blue: 0.09).opacity(0.16)
    static let primary = Color(red: 0.08, green: 0.08, blue: 0.075)
    static let secondary = Color(red: 0.26, green: 0.26, blue: 0.24)
    static let tertiary = Color(red: 0.42, green: 0.42, blue: 0.39)
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
    static let brandMark: CGFloat = 22
    static let compactBrandMark: CGFloat = 15
}

enum LTWidgetRadius {
    static let metric: CGFloat = 8
}
