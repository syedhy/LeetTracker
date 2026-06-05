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

    var mediumHardSolved: Int {
        mediumSolved + hardSolved
    }

    var mediumHardPercentText: String {
        percentText(for: mediumHardSolved)
    }

    var recommendedDifficulty: WidgetDifficulty {
        if mediumHardSolved == 0 {
            return .medium
        }

        if hardSolved == 0, totalSolved >= 20 {
            return .hard
        }

        return mediumSolved <= easySolved ? .medium : .hard
    }

    func percentText(for value: Int) -> String {
        guard totalSolved > 0 else {
            return "0%"
        }

        let percent = Int((Double(value) / Double(totalSolved) * 100).rounded())
        return "\(percent)%"
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

enum WidgetDifficulty: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var tint: Color {
        switch self {
        case .easy:
            return LTWidgetColor.easy
        case .medium:
            return LTWidgetColor.medium
        case .hard:
            return LTWidgetColor.hard
        }
    }

    var sessionCopy: String {
        switch self {
        case .easy:
            return "Warm up cleanly"
        case .medium:
            return "Build the core reps"
        case .hard:
            return "Pick one deep pattern"
        }
    }
}

extension SharedGoalSettings {
    var weeklyEasyDisplay: Int {
        weeklyEasyTarget ?? max(1, weeklyTarget / 4)
    }

    var weeklyMediumDisplay: Int {
        weeklyMediumTarget ?? max(1, weeklyTarget / 2)
    }

    var weeklyHardDisplay: Int {
        weeklyHardTarget ?? max(0, weeklyTarget - weeklyEasyDisplay - weeklyMediumDisplay)
    }

    var weeklyMixText: String {
        "\(weeklyEasyDisplay)E \(weeklyMediumDisplay)M \(weeklyHardDisplay)H"
    }

    func remaining(after solved: Int) -> Int {
        max(0, targetSolved - solved)
    }

    func progress(after solved: Int) -> Double {
        guard targetSolved > 0 else {
            return 0
        }

        return min(max(Double(solved) / Double(targetSolved), 0), 1)
    }

    func weeksRemaining(after solved: Int) -> Int {
        let remaining = remaining(after: solved)
        guard remaining > 0 else {
            return 0
        }

        return max(1, Int(ceil(Double(remaining) / Double(max(1, weeklyTarget)))))
    }
}

struct WidgetContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) {
                ZStack {
                    LTWidgetColor.cardBackground
                    WidgetPaperGrid()
                    WidgetDoodleBackdrop()
                        .stroke(LTWidgetColor.sketch.opacity(0.07), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .padding(6)
                }
            }
    }
}

struct WidgetPaperGrid: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 26
            var path = Path()

            stride(from: CGFloat.zero, through: size.width, by: spacing).forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            stride(from: CGFloat.zero, through: size.height, by: spacing).forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(path, with: .color(LTWidgetColor.paperLine), lineWidth: 1)
        }
    }
}

struct WidgetDoodleBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 10, y: rect.minY + 18))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 14, y: rect.minY + 30),
            control1: CGPoint(x: rect.midX * 0.56, y: rect.minY + 2),
            control2: CGPoint(x: rect.midX * 1.32, y: rect.minY + 42)
        )

        path.move(to: CGPoint(x: rect.minX + 12, y: rect.maxY - 22))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 10, y: rect.maxY - 34),
            control1: CGPoint(x: rect.midX * 0.70, y: rect.maxY - 44),
            control2: CGPoint(x: rect.midX * 1.35, y: rect.maxY - 10)
        )

        return path
    }
}

struct WidgetBrandMark: View {
    let isCompact: Bool

    init(isCompact: Bool = false) {
        self.isCompact = isCompact
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("</>")
                .font(.system(size: isCompact ? 12 : 15, weight: .black, design: .rounded))
                .foregroundStyle(LTWidgetColor.primary)
                .tracking(-1)

            HStack(spacing: 2) {
                Circle().fill(LTWidgetColor.easy)
                Circle().fill(LTWidgetColor.medium)
                Circle().fill(LTWidgetColor.hard)
            }
            .frame(width: isCompact ? 14 : 18, height: isCompact ? 4 : 5)
        }
        .frame(
            width: isCompact ? LTWidgetSizing.smallBrandIcon : LTWidgetSizing.brandIcon,
            height: isCompact ? LTWidgetSizing.smallBrandIcon : LTWidgetSizing.brandIcon
        )
        .background(LTWidgetColor.panel, in: RoundedRectangle(cornerRadius: isCompact ? 7 : 9))
        .overlay {
            RoundedRectangle(cornerRadius: isCompact ? 7 : 9)
                .stroke(LTWidgetColor.panelStroke, lineWidth: 1)
        }
    }
}

struct WidgetHeader: View {
    let title: String
    let isCompact: Bool

    init(title: String = "LeetCode", isCompact: Bool = false) {
        self.title = title
        self.isCompact = isCompact
    }

    var body: some View {
        HStack(spacing: LTWidgetSpacing.small) {
            WidgetBrandMark(isCompact: isCompact)

            Text(title)
                .font(isCompact ? LTWidgetTypography.compactTitle : LTWidgetTypography.title)
                .foregroundStyle(LTWidgetColor.brand)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
    }
}

struct WidgetDifficultySummary: View {
    enum Style {
        case compact
        case spacious
    }

    let stats: WidgetStatsSnapshot
    let style: Style

    init(stats: WidgetStatsSnapshot, style: Style = .spacious) {
        self.stats = stats
        self.style = style
    }

    var body: some View {
        switch style {
        case .compact:
            HStack(spacing: LTWidgetSpacing.small) {
                WidgetDifficultyChip(title: nil, value: stats.easySolved, tint: LTWidgetColor.easy, isCompact: true)
                WidgetDifficultyChip(title: nil, value: stats.mediumSolved, tint: LTWidgetColor.medium, isCompact: true)
                WidgetDifficultyChip(title: nil, value: stats.hardSolved, tint: LTWidgetColor.hard, isCompact: true)
            }
        case .spacious:
            HStack(spacing: LTWidgetSpacing.medium) {
                WidgetDifficultyCard(title: "Easy", value: stats.easySolved, percent: stats.percentText(for: stats.easySolved), tint: LTWidgetColor.easy)
                WidgetDifficultyCard(title: "Medium", value: stats.mediumSolved, percent: stats.percentText(for: stats.mediumSolved), tint: LTWidgetColor.medium)
                WidgetDifficultyCard(title: "Hard", value: stats.hardSolved, percent: stats.percentText(for: stats.hardSolved), tint: LTWidgetColor.hard)
            }
        }
    }
}

struct WidgetDifficultyCard: View {
    let title: String
    let value: Int
    let percent: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
            HStack(spacing: LTWidgetSpacing.compact) {
                Circle()
                    .fill(tint)
                    .frame(width: LTWidgetSizing.dot, height: LTWidgetSizing.dot)

                Text(title)
                    .font(LTWidgetTypography.label)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(percent)
                    .font(LTWidgetTypography.compactLabel)
                    .foregroundStyle(LTWidgetColor.tertiary)
                    .lineLimit(1)
            }

            Text("\(value)")
                .font(LTWidgetTypography.metricNumber)
                .foregroundStyle(LTWidgetColor.primary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, LTWidgetSpacing.medium)
        .padding(.vertical, LTWidgetSpacing.small)
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: LTWidgetRadius.miniPanel))
        .overlay(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(tint)
                .frame(height: 4)
                .padding(.horizontal, LTWidgetSpacing.medium)
                .padding(.bottom, 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: LTWidgetRadius.miniPanel)
                .stroke(tint.opacity(0.44), lineWidth: 1.1)
        }
    }
}

struct WidgetDifficultyChip: View {
    let title: String?
    let value: Int
    let tint: Color
    let isCompact: Bool

    var body: some View {
        HStack(spacing: LTWidgetSpacing.compact) {
            Circle()
                .fill(tint)
                .frame(width: isCompact ? LTWidgetSizing.compactDot : LTWidgetSizing.dot, height: isCompact ? LTWidgetSizing.compactDot : LTWidgetSizing.dot)

            if let title {
                Text(title)
                    .font(LTWidgetTypography.compactLabel)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            Text("\(value)")
                .font(isCompact ? LTWidgetTypography.compactMetricNumber : LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.primary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, isCompact ? 7 : 9)
        .padding(.vertical, isCompact ? 5 : 6)
        .frame(maxWidth: .infinity)
        .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: LTWidgetRadius.badge))
    }
}

struct WidgetProgressBar: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(progress, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LTWidgetColor.primary.opacity(0.10))

                Capsule()
                    .fill(tint)
                    .frame(width: max(8, proxy.size.width * clamped))
            }
        }
        .frame(height: 8)
    }
}

struct WidgetCallout: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: LTWidgetSpacing.medium) {
            Image(systemName: "arrow.up.right")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: Circle())
                .overlay {
                    Circle().stroke(tint.opacity(0.55), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LTWidgetTypography.label)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(detail)
                    .font(LTWidgetTypography.caption)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
        }
    }
}

struct WidgetUpdatedText: View {
    let date: Date

    var body: some View {
        Text("Updated \(Self.timeFormatter.string(from: date))")
            .font(LTWidgetTypography.caption)
            .foregroundStyle(LTWidgetColor.tertiary)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
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
                .frame(width: LTWidgetSizing.compactDot, height: LTWidgetSizing.compactDot)

            Text(text)
                .font(LTWidgetTypography.caption)
                .foregroundStyle(LTWidgetColor.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
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

            Spacer(minLength: LTWidgetSpacing.small)

            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                Text(title)
                    .font(LTWidgetTypography.stateTitle)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(message)
                    .font(LTWidgetTypography.caption)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(LTWidgetSpacing.smallPadding)
    }
}

struct WidgetErrorStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader()

            Spacer(minLength: LTWidgetSpacing.small)

            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                WidgetStatusPill(text: "Needs attention", tint: LTWidgetColor.error)

                Text(title)
                    .font(LTWidgetTypography.stateTitle)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(message)
                    .font(LTWidgetTypography.caption)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(LTWidgetSpacing.smallPadding)
    }
}

struct WidgetLoadingStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader()

            Spacer(minLength: LTWidgetSpacing.small)

            VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
                Text("Updating stats")
                    .font(LTWidgetTypography.stateTitle)
                    .foregroundStyle(LTWidgetColor.primary)

                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    RoundedRectangle(cornerRadius: LTWidgetRadius.badge)
                        .fill(LTWidgetColor.panel)
                        .frame(width: 92, height: 12)

                    RoundedRectangle(cornerRadius: LTWidgetRadius.badge)
                        .fill(LTWidgetColor.panel)
                        .frame(width: 132, height: 12)

                    RoundedRectangle(cornerRadius: LTWidgetRadius.badge)
                        .fill(LTWidgetColor.panel)
                        .frame(width: 72, height: 12)
                }
            }
        }
        .padding(LTWidgetSpacing.smallPadding)
    }
}
