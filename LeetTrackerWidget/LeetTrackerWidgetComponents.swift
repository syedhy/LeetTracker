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
    }
}

struct WidgetStatRow: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        WidgetDifficultyMetric(title: title, value: value, tint: tint)
    }
}

struct WidgetDifficultySummary: View {
    let stats: CachedLeetCodeStats

    var body: some View {
        HStack(alignment: .top, spacing: LTWidgetSpacing.medium) {
            WidgetDifficultyMetric(title: "Easy", value: stats.easySolved, tint: LTWidgetColor.easy)
            WidgetDifficultyMetric(title: "Medium", value: stats.mediumSolved, tint: LTWidgetColor.medium)
            WidgetDifficultyMetric(title: "Hard", value: stats.hardSolved, tint: LTWidgetColor.hard)
        }
    }
}

struct WidgetDifficultyMetric: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
            HStack(spacing: LTWidgetSpacing.compact) {
                Circle()
                    .fill(tint)
                    .frame(width: LTWidgetSizing.difficultyDot, height: LTWidgetSizing.difficultyDot)

                Text(title)
                    .font(LTWidgetTypography.statLabel)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Text("\(value)")
                .font(LTWidgetTypography.statNumber)
                .contentTransition(.numericText())
                .foregroundStyle(LTWidgetColor.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, LTWidgetSpacing.medium)
        .padding(.vertical, LTWidgetSpacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LTWidgetColor.panel, in: RoundedRectangle(cornerRadius: LTWidgetRadius.metric))
        .overlay {
            RoundedRectangle(cornerRadius: LTWidgetRadius.metric)
                .stroke(LTWidgetColor.panelStroke, lineWidth: 1)
        }
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
                WidgetBrandMark()

                brandText

                Spacer(minLength: LTWidgetSpacing.medium)
            }
        } else {
            HStack(alignment: .center, spacing: LTWidgetSpacing.small) {
                WidgetBrandMark()
                brandText
            }
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
        Circle()
            .fill(LTWidgetColor.brand)
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
        Text("Updated \(Self.timeFormatter.string(from: date))")
            .font(LTWidgetTypography.label)
            .foregroundStyle(LTWidgetColor.tertiary)
            .lineLimit(1)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
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
