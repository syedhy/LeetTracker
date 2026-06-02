import SwiftUI

enum LTWidgetSpacing {
    static let xSmall: CGFloat = 2
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let contentPadding: CGFloat = 0
}

enum LTWidgetTypography {
    static let title = Font.headline
    static let primaryNumber = Font.system(size: 42, weight: .semibold, design: .rounded)
    static let mediumNumber = Font.title.weight(.semibold)
    static let label = Font.caption
    static let emptyState = Font.subheadline.weight(.medium)
}

enum LTWidgetColor {
    static let primary = Color.primary
    static let secondary = Color.secondary
}

enum LTWidgetSizing {
    static let minimumReadableWidth: CGFloat = 44
}
