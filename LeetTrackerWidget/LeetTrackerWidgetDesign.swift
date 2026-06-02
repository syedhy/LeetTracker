import SwiftUI

enum LTWidgetSpacing {
    static let xSmall: CGFloat = 2
    static let compact: CGFloat = 4
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xLarge: CGFloat = 16
    static let xxLarge: CGFloat = 20
    static let contentPadding: CGFloat = 0
}

enum LTWidgetTypography {
    static let title = Font.caption.weight(.semibold)
    static let user = Font.subheadline.weight(.medium)
    static let primaryNumber = Font.system(size: 52, weight: .semibold, design: .rounded)
    static let mediumNumber = Font.system(size: 58, weight: .semibold, design: .rounded)
    static let statNumber = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let label = Font.caption
    static let statLabel = Font.caption.weight(.medium)
    static let emptyState = Font.subheadline.weight(.medium)
    static let stateTitle = Font.headline.weight(.semibold)
}

enum LTWidgetColor {
    static let cardBackground = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.09, blue: 0.12),
            Color(red: 0.03, green: 0.04, blue: 0.06)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let panel = Color.white.opacity(0.07)
    static let panelStroke = Color.white.opacity(0.08)
    static let divider = Color.white.opacity(0.10)
    static let primary = Color.white
    static let secondary = Color.white.opacity(0.70)
    static let tertiary = Color.white.opacity(0.46)
    static let brand = Color(red: 0.35, green: 0.76, blue: 1.00)
    static let easy = Color(red: 0.30, green: 0.84, blue: 0.44)
    static let medium = Color(red: 1.00, green: 0.62, blue: 0.10)
    static let hard = Color(red: 1.00, green: 0.31, blue: 0.52)
    static let warning = Color(red: 1.00, green: 0.70, blue: 0.24)
    static let error = Color(red: 1.00, green: 0.34, blue: 0.44)
}

enum LTWidgetSizing {
    static let minimumReadableWidth: CGFloat = 44
    static let mediumValueWidth: CGFloat = 64
    static let difficultyDot: CGFloat = 7
    static let brandMark: CGFloat = 8
}

enum LTWidgetRadius {
    static let card: CGFloat = 22
    static let metric: CGFloat = 12
}
