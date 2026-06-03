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
                return LTWidgetSpacing.xLarge
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
        HStack(alignment: .top, spacing: style.spacing) {
            WidgetDifficultyMetric(title: "Easy", value: stats.easySolved, tint: LTWidgetColor.easy, style: style)
            WidgetDifficultyMetric(title: "Medium", value: stats.mediumSolved, tint: LTWidgetColor.medium, style: style)
            WidgetDifficultyMetric(title: "Hard", value: stats.hardSolved, tint: LTWidgetColor.hard, style: style)
        }
    }
}

struct WidgetDifficultyMetric: View {
    let title: String
    let value: Int
    let tint: Color
    let style: WidgetDifficultySummary.Style

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
            return CGSize(width: 39, height: 28)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WidgetHeader: View {
    let style: WidgetDifficultySummary.Style

    init(style: WidgetDifficultySummary.Style = .spacious) {
        self.style = style
    }

    var body: some View {
        HStack(alignment: .center, spacing: style == .compact ? LTWidgetSpacing.small : LTWidgetSpacing.medium) {
            WidgetBrandMark(style: style)

            Text("LeetTracker")
                .font(style == .compact ? LTWidgetTypography.compactTitle : LTWidgetTypography.title)
                .foregroundStyle(LTWidgetColor.brand)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }
}

struct WidgetBrandMark: View {
    let style: WidgetDifficultySummary.Style

    private var markSize: CGFloat {
        style == .compact ? LTWidgetSizing.compactBrandMark : LTWidgetSizing.brandMark
    }

    var body: some View {
        VStack(spacing: style == .compact ? 1 : 3) {
            WidgetCodeMarkShape()
                .fill(LTWidgetColor.primary)
                .frame(width: markSize, height: markSize * 0.70)

            HStack(spacing: style == .compact ? 2 : 3) {
                Circle()
                    .fill(LTWidgetColor.easy)
                Circle()
                    .fill(LTWidgetColor.medium)
                Circle()
                    .fill(LTWidgetColor.hard)
            }
            .frame(width: markSize * 0.52, height: style == .compact ? 3 : 5)
        }
        .frame(width: markSize, height: markSize)
    }
}

struct WidgetCodeMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lineWidth = rect.height * 0.25
        let leftX = rect.minX + rect.width * 0.29
        let rightX = rect.minX + rect.width * 0.71
        let midY = rect.midY
        let chevronHeight = rect.height * 0.30
        let chevronWidth = rect.width * 0.17

        var left = Path()
        left.move(to: CGPoint(x: leftX, y: midY - chevronHeight))
        left.addLine(to: CGPoint(x: leftX - chevronWidth, y: midY))
        left.addLine(to: CGPoint(x: leftX, y: midY + chevronHeight))
        path.addPath(left.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)))

        var slash = Path()
        slash.move(to: CGPoint(x: rect.midX + rect.width * 0.07, y: rect.minY + rect.height * 0.12))
        slash.addLine(to: CGPoint(x: rect.midX - rect.width * 0.07, y: rect.maxY - rect.height * 0.12))
        path.addPath(slash.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)))

        var right = Path()
        right.move(to: CGPoint(x: rightX, y: midY - chevronHeight))
        right.addLine(to: CGPoint(x: rightX + chevronWidth, y: midY))
        right.addLine(to: CGPoint(x: rightX, y: midY + chevronHeight))
        path.addPath(right.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)))

        return path
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
