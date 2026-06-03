import Foundation
import SwiftUI
import WidgetKit

struct WidgetStatsSnapshot: Equatable {
    let username: String
    let totalSolved: Int
    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int
    let lastUpdated: Date
}

extension WidgetStatsSnapshot {
    init(cachedStats: CachedLeetCodeStats) {
        self.init(
            username: cachedStats.username,
            totalSolved: cachedStats.totalSolved,
            easySolved: cachedStats.easySolved,
            mediumSolved: cachedStats.mediumSolved,
            hardSolved: cachedStats.hardSolved,
            lastUpdated: cachedStats.lastUpdated
        )
    }

    static let placeholder = WidgetStatsSnapshot(
        username: "leetcode-user",
        totalSolved: 128,
        easySolved: 54,
        mediumSolved: 61,
        hardSolved: 13,
        lastUpdated: Date()
    )
}

struct WidgetContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(LTWidgetSpacing.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) {
                ZStack {
                    LTWidgetColor.cardBackground
                    WidgetDoodleBackdrop()
                        .stroke(LTWidgetColor.primary.opacity(0.045), lineWidth: 1)
                        .padding(4)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: LTWidgetRadius.metric)
                    .stroke(LTWidgetColor.primary.opacity(0.14), lineWidth: 1)
            }
    }
}

struct WidgetDoodleBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 8, y: rect.minY + 18))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 12, y: rect.minY + 28),
            control1: CGPoint(x: rect.midX * 0.55, y: rect.minY + 4),
            control2: CGPoint(x: rect.midX * 1.28, y: rect.minY + 42)
        )

        path.move(to: CGPoint(x: rect.minX + 10, y: rect.maxY - 22))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 8, y: rect.maxY - 34),
            control1: CGPoint(x: rect.midX * 0.65, y: rect.maxY - 44),
            control2: CGPoint(x: rect.midX * 1.35, y: rect.maxY - 10)
        )

        path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY + 8))
        path.addCurve(
            to: CGPoint(x: rect.minX + 30, y: rect.maxY - 8),
            control1: CGPoint(x: rect.minX + 46, y: rect.midY * 0.76),
            control2: CGPoint(x: rect.minX + 2, y: rect.midY * 1.22)
        )

        return path
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
        .padding(.vertical, LTWidgetSpacing.xSmall)
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
        Image(systemName: "chevron.left.forwardslash.chevron.right")
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(LTWidgetColor.primary)
            .frame(width: LTWidgetSizing.brandMark, height: LTWidgetSizing.brandMark)
            .overlay(alignment: .bottom) {
                HStack(spacing: 2) {
                    Circle()
                        .fill(LTWidgetColor.easy)
                    Circle()
                        .fill(LTWidgetColor.medium)
                    Circle()
                        .fill(LTWidgetColor.hard)
                }
                .frame(width: 14, height: 3)
                .offset(y: 3)
            }
        .frame(width: LTWidgetSizing.brandMark, height: LTWidgetSizing.brandMark)
        .rotationEffect(.degrees(-4))
    }
}

struct WidgetDivider: View {
    var body: some View {
        Rectangle()
            .fill(LTWidgetColor.primary.opacity(0.14))
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
