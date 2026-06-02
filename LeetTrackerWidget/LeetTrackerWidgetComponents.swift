import Foundation
import SwiftUI
import WidgetKit

struct WidgetContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) {
                LTWidgetColor.cardBackground
            }
            .overlay {
                RoundedRectangle(cornerRadius: LTWidgetRadius.card)
                    .stroke(LTWidgetColor.cardStroke, lineWidth: 1)
            }
    }
}

struct WidgetStatRow: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        HStack(spacing: LTWidgetSpacing.medium) {
            Circle()
                .fill(tint)
                .frame(width: LTWidgetSizing.difficultyDot, height: LTWidgetSizing.difficultyDot)

            Text(title)
                .font(LTWidgetTypography.statLabel)
                .foregroundStyle(LTWidgetColor.primary)

            Spacer(minLength: LTWidgetSpacing.medium)

            Text("\(value)")
                .font(LTWidgetTypography.statLabel.weight(.semibold))
                .contentTransition(.numericText())
                .foregroundStyle(tint)
                .frame(minWidth: LTWidgetSizing.mediumValueWidth, alignment: .trailing)
        }
    }
}

struct WidgetDifficultySummary: View {
    let stats: CachedLeetCodeStats

    var body: some View {
        HStack(alignment: .top, spacing: LTWidgetSpacing.large) {
            difficultyColumn(title: "Easy", value: stats.easySolved, tint: LTWidgetColor.easy)
            difficultyColumn(title: "Medium", value: stats.mediumSolved, tint: LTWidgetColor.medium)
            difficultyColumn(title: "Hard", value: stats.hardSolved, tint: LTWidgetColor.hard)
        }
    }

    private func difficultyColumn(title: String, value: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
            Text("\(value)")
                .font(LTWidgetTypography.statNumber)
                .contentTransition(.numericText())
                .foregroundStyle(tint)

            Text(title)
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WidgetHeader: View {
    let showMark: Bool

    init(showMark: Bool = false) {
        self.showMark = showMark
    }

    @ViewBuilder
    var body: some View {
        if showMark {
            HStack(alignment: .center) {
                brandText

                Spacer(minLength: LTWidgetSpacing.medium)

                WidgetBrandMark()
            }
        } else {
            brandText
        }
    }

    private var brandText: some View {
        Text("LeetTracker")
            .font(LTWidgetTypography.title)
            .foregroundStyle(LTWidgetColor.brand)
            .lineLimit(1)
    }
}

struct WidgetBrandMark: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.08))

            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(LTWidgetColor.medium)
        }
        .frame(width: LTWidgetSizing.brandMark, height: LTWidgetSizing.brandMark)
    }
}

struct WidgetHairline: View {
    var body: some View {
        Rectangle()
            .fill(LTWidgetColor.divider)
            .frame(height: 1)
    }
}

struct WidgetUpdatedText: View {
    let date: Date

    var body: some View {
        Text("Updated \(Self.relativeFormatter.localizedString(for: date, relativeTo: Date()))")
            .font(LTWidgetTypography.label)
            .foregroundStyle(LTWidgetColor.tertiary)
            .lineLimit(1)
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

struct WidgetEmptyStateView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(showMark: true)

            Spacer()

            Text(message)
                .font(LTWidgetTypography.emptyState)
                .foregroundStyle(LTWidgetColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WidgetErrorStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            Text("LeetTracker")
                .font(LTWidgetTypography.title)
                .foregroundStyle(LTWidgetColor.brand)

            Spacer()

            Text(title)
                .font(LTWidgetTypography.emptyState)
                .foregroundStyle(LTWidgetColor.primary)

            Text(message)
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WidgetLoadingStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(showMark: true)

            Spacer()

            Text("Updating stats...")
                .font(LTWidgetTypography.emptyState)
                .foregroundStyle(LTWidgetColor.secondary)
        }
    }
}
