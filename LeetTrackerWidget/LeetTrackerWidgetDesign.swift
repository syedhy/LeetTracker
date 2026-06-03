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
    static let title = Font.caption.weight(.semibold)
    static let user = Font.subheadline.weight(.medium)
    static let primaryNumber = Font.system(size: 52, weight: .semibold, design: .rounded)
    static let mediumNumber = Font.system(size: 58, weight: .semibold, design: .rounded)
    static let statNumber = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let label = Font.caption
    static let statLabel = Font.caption.weight(.medium)
    static let stateTitle = Font.headline.weight(.semibold)
}

enum LTWidgetColor {
    static let cardBackground = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.975, blue: 0.94),
            Color(red: 0.92, green: 0.91, blue: 0.86)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let panel = Color(red: 0.94, green: 0.93, blue: 0.88).opacity(0.85)
    static let panelStroke = Color(red: 0.10, green: 0.10, blue: 0.09).opacity(0.28)
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
    static let difficultyDot: CGFloat = 7
    static let brandMark: CGFloat = 8
}

enum LTWidgetRadius {
    static let metric: CGFloat = 8
}
