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
            .padding(0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) {
                LTWidgetColor.cardBackground
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
    enum Style: Equatable {
        case compact
        case spacious

        var spacing: CGFloat {
            switch self {
            case .compact:
                return LTWidgetSpacing.small
            case .spacious:
                return 0
            }
        }
    }

    let stats: WidgetStatsSnapshot
    let style: Style

    init(stats: WidgetStatsSnapshot, style: Style = .spacious) {
        self.stats = stats
        self.style = style
    }

    var body: some View {
        if style == .compact {
            HStack(alignment: .top, spacing: style.spacing) {
                WidgetDifficultyMetric(title: "Easy", value: stats.easySolved, tint: LTWidgetColor.easy, style: style)
                WidgetDifficultyMetric(title: "Medium", value: stats.mediumSolved, tint: LTWidgetColor.medium, style: style)
                WidgetDifficultyMetric(title: "Hard", value: stats.hardSolved, tint: LTWidgetColor.hard, style: style)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(alignment: .top, spacing: 0) {
                WidgetDifficultyMetric(
                    title: "Easy",
                    value: stats.easySolved,
                    tint: LTWidgetColor.easy,
                    style: style,
                    metricAlignment: .leading,
                    frameAlignment: .leading
                )
                WidgetDifficultyMetric(title: "Medium", value: stats.mediumSolved, tint: LTWidgetColor.medium, style: style)
                WidgetDifficultyMetric(
                    title: "Hard",
                    value: stats.hardSolved,
                    tint: LTWidgetColor.hard,
                    style: style,
                    metricAlignment: .trailing,
                    frameAlignment: .trailing
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct WidgetDifficultyMetric: View {
    let title: String
    let value: Int
    let tint: Color
    let style: WidgetDifficultySummary.Style
    let metricAlignmentOverride: HorizontalAlignment?
    let frameAlignmentOverride: Alignment?

    init(
        title: String,
        value: Int,
        tint: Color,
        style: WidgetDifficultySummary.Style,
        metricAlignment: HorizontalAlignment? = nil,
        frameAlignment: Alignment? = nil
    ) {
        self.title = title
        self.value = value
        self.tint = tint
        self.style = style
        self.metricAlignmentOverride = metricAlignment
        self.frameAlignmentOverride = frameAlignment
    }

    private var dotSize: CGFloat {
        style == .compact ? LTWidgetSizing.compactDifficultyDot : LTWidgetSizing.difficultyDot
    }

    private var labelFont: Font {
        style == .compact ? LTWidgetTypography.compactStatLabel : LTWidgetTypography.statLabel
    }

    private var valueFont: Font {
        style == .compact ? LTWidgetTypography.compactStatNumber : LTWidgetTypography.statNumber
    }

    private var badgeSize: CGSize {
        switch style {
        case .compact:
            return CGSize(width: 31, height: 25)
        case .spacious:
            return CGSize(width: 36, height: 26)
        }
    }

    private var metricAlignment: HorizontalAlignment {
        if let metricAlignmentOverride {
            return metricAlignmentOverride
        }

        return style == .compact ? HorizontalAlignment.leading : HorizontalAlignment.center
    }

    private var frameAlignment: Alignment {
        if let frameAlignmentOverride {
            return frameAlignmentOverride
        }

        return style == .compact ? Alignment.leading : Alignment.center
    }

    var body: some View {
        VStack(alignment: metricAlignment, spacing: LTWidgetSpacing.small) {
            HStack(spacing: LTWidgetSpacing.compact) {
                Circle()
                    .fill(tint)
                    .frame(width: dotSize, height: dotSize)

                Text(title)
                    .font(labelFont)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }

            Text("\(value)")
                .font(valueFont)
                .contentTransition(.numericText())
                .foregroundStyle(LTWidgetColor.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(width: badgeSize.width, height: badgeSize.height)
                .background(tint.opacity(0.24), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, LTWidgetSpacing.xSmall)
        .frame(maxWidth: .infinity, alignment: frameAlignment)
    }
}

struct WidgetCompactDifficultyStrip: View {
    let stats: WidgetStatsSnapshot

    var body: some View {
        HStack(spacing: LTWidgetSpacing.small) {
            WidgetCompactDifficultyCount(value: stats.easySolved, tint: LTWidgetColor.easy)
            WidgetCompactDifficultyCount(value: stats.mediumSolved, tint: LTWidgetColor.medium)
            WidgetCompactDifficultyCount(value: stats.hardSolved, tint: LTWidgetColor.hard)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WidgetCompactDifficultyCount: View {
    let value: Int
    let tint: Color

    var body: some View {
        HStack(spacing: LTWidgetSpacing.compact) {
            Circle()
                .fill(tint)
                .frame(width: LTWidgetSizing.compactDifficultyDot, height: LTWidgetSizing.compactDifficultyDot)

            Text("\(value)")
                .font(LTWidgetTypography.miniStatNumber)
                .foregroundStyle(LTWidgetColor.primary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, LTWidgetSpacing.small)
        .padding(.vertical, LTWidgetSpacing.compact)
        .frame(maxWidth: .infinity)
        .background(tint.opacity(0.20), in: RoundedRectangle(cornerRadius: LTWidgetRadius.metric))
    }
}

struct WidgetHeader: View {
    let style: WidgetDifficultySummary.Style

    init(style: WidgetDifficultySummary.Style = .spacious) {
        self.style = style
    }

    var body: some View {
        Text("LeetCode")
            .font(style == .compact ? LTWidgetTypography.compactTitle : LTWidgetTypography.title)
            .foregroundStyle(LTWidgetColor.brand)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
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
            WidgetHeader()

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
        .padding(LTWidgetSpacing.xLarge)
    }
}

struct WidgetErrorStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader()

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
        .padding(LTWidgetSpacing.xLarge)
    }
}

struct WidgetLoadingStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader()

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
        .padding(LTWidgetSpacing.xLarge)
    }
}
