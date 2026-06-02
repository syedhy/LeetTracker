import SwiftUI

enum LTWidgetSpacing {
    static let xSmall: CGFloat = 2
    static let compact: CGFloat = 4
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xLarge: CGFloat = 16
    static let contentPadding: CGFloat = 0
}

enum LTWidgetTypography {
    static let title = Font.subheadline.weight(.semibold)
    static let user = Font.title3.weight(.semibold)
    static let primaryNumber = Font.system(size: 46, weight: .semibold, design: .rounded)
    static let mediumNumber = Font.system(size: 42, weight: .semibold, design: .rounded)
    static let statNumber = Font.title3.weight(.semibold)
    static let label = Font.caption
    static let statLabel = Font.callout
    static let emptyState = Font.subheadline.weight(.medium)
}

enum LTWidgetColor {
    static let cardBackground = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.10, blue: 0.12),
            Color(red: 0.05, green: 0.07, blue: 0.09)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardStroke = Color.white.opacity(0.10)
    static let divider = Color.white.opacity(0.14)
    static let primary = Color.white
    static let secondary = Color.white.opacity(0.68)
    static let tertiary = Color.white.opacity(0.48)
    static let brand = Color(red: 0.24, green: 0.70, blue: 1.00)
    static let easy = Color(red: 0.30, green: 0.84, blue: 0.44)
    static let medium = Color(red: 1.00, green: 0.62, blue: 0.10)
    static let hard = Color(red: 1.00, green: 0.31, blue: 0.52)
}

enum LTWidgetSizing {
    static let minimumReadableWidth: CGFloat = 44
    static let mediumValueWidth: CGFloat = 64
    static let difficultyDot: CGFloat = 9
    static let brandMark: CGFloat = 28
}

enum LTWidgetRadius {
    static let card: CGFloat = 24
    static let brandMark: CGFloat = 14
}
