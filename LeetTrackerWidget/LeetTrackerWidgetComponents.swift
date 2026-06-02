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

struct WidgetDifficultySummary: View {
    let stats: WidgetStatsSnapshot

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

struct WidgetStatusPill: View {
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: LTWidgetSpacing.compact) {
            Circle()
                .fill(tint)
                .frame(width: LTWidgetSizing.difficultyDot, height: LTWidgetSizing.difficultyDot)

            Text(text)
                .font(LTWidgetTypography.label.weight(.medium))
                .foregroundStyle(LTWidgetColor.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, LTWidgetSpacing.medium)
        .padding(.vertical, LTWidgetSpacing.small)
        .background(LTWidgetColor.panel, in: Capsule())
        .overlay {
            Capsule()
                .stroke(LTWidgetColor.panelStroke, lineWidth: 1)
        }
    }
}

struct WidgetEmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(showMark: true)

            Spacer()

            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                Text(title)
                    .font(LTWidgetTypography.stateTitle)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(message)
                    .font(LTWidgetTypography.label)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct WidgetErrorStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(showMark: true)

            Spacer()

            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                WidgetStatusPill(text: "Needs attention", tint: LTWidgetColor.error)

                Text(title)
                    .font(LTWidgetTypography.stateTitle)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(message)
                    .font(LTWidgetTypography.label)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct WidgetLoadingStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(showMark: true)

            Spacer()

            VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
                Text("Updating stats")
                    .font(LTWidgetTypography.stateTitle)
                    .foregroundStyle(LTWidgetColor.primary)

                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    RoundedRectangle(cornerRadius: LTWidgetRadius.metric)
                        .fill(LTWidgetColor.panel)
                        .frame(width: 92, height: 12)

                    RoundedRectangle(cornerRadius: LTWidgetRadius.metric)
                        .fill(LTWidgetColor.panel)
                        .frame(width: 132, height: 12)

                    RoundedRectangle(cornerRadius: LTWidgetRadius.metric)
                        .fill(LTWidgetColor.panel)
                        .frame(width: 72, height: 12)
                }
            }
        }
    }
}
