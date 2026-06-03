import SwiftUI

struct AnalyticsHeroPanel: View {
    let stats: LeetCodeStats?
    let history: [LeetCodeStats]
    let rows: [DifficultyDistributionRow]
    let score: Int
    let title: String
    let detail: String
    let targetSolved: Int
    let weeklyTarget: Int
    let completionText: String
    let focusTitle: String
    let focusDetail: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Practice Map", systemImage: "chart.line.uptrend.xyaxis")

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 24) {
                        heroGraph
                            .frame(minWidth: 360, idealWidth: 520, maxWidth: .infinity)

                        heroCopy
                            .frame(minWidth: 300, idealWidth: 380, maxWidth: 440)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        heroGraph
                        heroCopy
                    }
                }
            }
        }
    }

    private var heroGraph: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(stats.map { "\($0.totalSolved)" } ?? "--")
                            .font(.system(size: 52, weight: .semibold, design: .rounded))
                            .monospacedDigit()

                        Text("solved")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    Text("Actual trend")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()

                    Text("practice health")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            PracticeTrendLineGraph(
                samples: graphSamples,
                targetSolved: targetSolved,
                weeklyTarget: weeklyTarget,
                rows: rows
            )
                .frame(height: 210)

            HStack(spacing: 10) {
                AnalyticsHeroBadge(title: "Target", value: "\(targetSolved)")
                AnalyticsHeroBadge(title: "Weekly", value: "\(weeklyTarget)")
                AnalyticsHeroBadge(title: "Finish", value: completionText)
            }
        }
    }

    private var graphSamples: [LeetCodeStats] {
        let samples = history.isEmpty ? stats.map { [$0] } ?? [] : history
        return Array(samples.suffix(12))
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.title.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(focusTint)
                    .frame(width: 44, height: 44)
                    .background(AppColor.paperWarm.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focusTint.opacity(0.42), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 5) {
                    Text(focusTitle)
                        .font(.title3.weight(.semibold))

                    Text(focusDetail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var focusTint: Color {
        switch focusTitle {
        case "Add one Hard":
            return AppColor.hard
        case "Lean into Medium":
            return AppColor.medium
        case "Finish the goal":
            return AppColor.easy
        default:
            return AppColor.ink
        }
    }
}

struct AnalyticsHeroBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.callout.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.paperWarm.opacity(0.62), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.line.opacity(0.22), lineWidth: 1)
        }
    }
}

struct PracticeTrendLineGraph: View {
    let samples: [LeetCodeStats]
    let targetSolved: Int
    let weeklyTarget: Int
    let rows: [DifficultyDistributionRow]

    private var minValue: Int {
        max(0, values.min() ?? 0)
    }

    private var maxValue: Int {
        max(values.max() ?? 1, targetSolved, 1)
    }

    private var range: Int {
        max(1, maxValue - minValue)
    }

    private var values: [Int] {
        samples.map(\.totalSolved)
    }

    private var currentSolved: Int {
        samples.last?.totalSolved ?? 0
    }

    private var projectedSolved: Int {
        min(max(targetSolved, currentSolved), currentSolved + max(1, weeklyTarget))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { proxy in
                let chartRect = CGRect(
                    x: 24,
                    y: 16,
                    width: max(1, proxy.size.width - 48),
                    height: max(1, proxy.size.height - 54)
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.paperWarm.opacity(0.44))

                    graphGrid(in: chartRect)

                    targetPath(in: chartRect)
                        .stroke(
                            AppColor.line.opacity(0.36),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [5, 5])
                        )

                    actualPath(in: chartRect)
                        .stroke(AppColor.ink, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    ForEach(Array(samples.enumerated()), id: \.element.lastUpdated) { index, sample in
                        let position = actualPointPosition(index: index, value: sample.totalSolved, rect: chartRect)

                        VStack(spacing: 5) {
                            Text("\(sample.totalSolved)")
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(AppColor.paper, in: Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(AppColor.line.opacity(0.22), lineWidth: 1)
                                }

                            Circle()
                                .fill(index == samples.count - 1 ? AppColor.ink : AppColor.graphite)
                                .frame(width: 13, height: 13)
                                .overlay {
                                    Circle()
                                        .stroke(AppColor.paper, lineWidth: 3)
                                }
                        }
                        .position(x: position.x, y: max(20, position.y - 22))
                    }

                    targetMarker(in: chartRect)

                    Text(axisStartLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .position(x: chartRect.minX, y: chartRect.maxY + 23)

                    Text(axisEndLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .position(x: chartRect.maxX, y: chartRect.maxY + 23)
                }
            }

            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Capsule()
                        .fill(AppColor.ink)
                        .frame(width: 18, height: 3)

                    Text("Actual")
                        .font(.caption.weight(.semibold))
                }

                HStack(spacing: 6) {
                    Capsule()
                        .fill(AppColor.line.opacity(0.36))
                        .frame(width: 18, height: 3)

                    Text("Target pace")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                ForEach(rows) { row in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(row.tint)
                            .frame(width: 8, height: 8)

                        Text(row.title)
                            .font(.caption.weight(.semibold))

                        Text("\(row.percentage)%")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
    }

    private var axisStartLabel: String {
        guard let first = samples.first else {
            return "No data"
        }

        if samples.count == 1 {
            return "First sample"
        }

        return timeLabel(for: first.lastUpdated)
    }

    private var axisEndLabel: String {
        guard let last = samples.last else {
            return "Refresh"
        }

        return timeLabel(for: last.lastUpdated)
    }

    private func graphGrid(in rect: CGRect) -> some View {
        Path { path in
            for index in 0...3 {
                let y = rect.minY + rect.height * CGFloat(index) / 3
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
        }
        .stroke(AppColor.line.opacity(0.12), lineWidth: 1)
    }

    private func actualPath(in rect: CGRect) -> Path {
        var path = Path()

        guard !samples.isEmpty else {
            return path
        }

        for (index, sample) in samples.enumerated() {
            let position = actualPointPosition(index: index, value: sample.totalSolved, rect: rect)

            if index == 0 {
                path.move(to: position)
            } else {
                path.addLine(to: position)
            }
        }

        return path
    }

    private func targetPath(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(
            x: rect.minX,
            y: yPosition(for: currentSolved, rect: rect)
        )
        let end = CGPoint(
            x: rect.maxX,
            y: yPosition(for: projectedSolved, rect: rect)
        )

        path.move(to: start)
        path.addLine(to: end)
        return path
    }

    private func targetMarker(in rect: CGRect) -> some View {
        let position = CGPoint(
            x: rect.maxX,
            y: yPosition(for: projectedSolved, rect: rect)
        )

        return VStack(spacing: 5) {
            Text("\(projectedSolved)")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(AppColor.paper, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColor.line.opacity(0.22), lineWidth: 1)
                }

            Circle()
                .fill(AppColor.medium)
                .frame(width: 11, height: 11)
                .overlay {
                    Circle()
                        .stroke(AppColor.paper, lineWidth: 3)
                }
        }
        .position(x: position.x, y: max(20, position.y - 22))
    }

    private func actualPointPosition(index: Int, value: Int, rect: CGRect) -> CGPoint {
        let count = max(1, samples.count - 1)
        let x = rect.minX + rect.width * CGFloat(index) / CGFloat(count)
        let y = yPosition(for: value, rect: rect)
        return CGPoint(x: x, y: y)
    }

    private func yPosition(for value: Int, rect: CGRect) -> CGFloat {
        let normalized = CGFloat(value - minValue) / CGFloat(range)
        let y = rect.maxY - rect.height * normalized
        return y
    }

    private func timeLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

struct DifficultyBreakdownPanel: View {
    let stats: LeetCodeStats?

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Difficulty Breakdown", systemImage: "chart.bar.fill")

                if let stats, stats.totalSolved > 0 {
                    VStack(spacing: 12) {
                        DifficultyBarRow(title: "Easy", value: stats.easySolved, total: stats.totalSolved, tint: AppColor.easy)
                        DifficultyBarRow(title: "Medium", value: stats.mediumSolved, total: stats.totalSolved, tint: AppColor.medium)
                        DifficultyBarRow(title: "Hard", value: stats.hardSolved, total: stats.totalSolved, tint: AppColor.hard)
                    }

                    Text("This shows where your solved count is concentrated. A stronger practice mix usually grows Medium problems steadily while keeping Easy warmups active.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    EmptyPanelMessage(
                        title: "No analytics yet",
                        message: "Save a LeetCode username and refresh once to generate readable charts."
                    )
                }
            }
        }
    }
}

struct DifficultyBarRow: View {
    let title: String
    let value: Int
    let total: Int
    let tint: Color

    private var percentage: Int {
        guard total > 0 else {
            return 0
        }

        return Int((Double(value) / Double(total) * 100).rounded())
    }

    private var progress: Double {
        guard total > 0 else {
            return 0
        }

        return Double(value) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(tint)
                        .frame(width: 9, height: 9)

                    Text(title)
                        .font(.callout.weight(.semibold))
                }

                Spacer()

                Text("\(value) · \(percentage)%")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary.opacity(0.58))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(tint.gradient)
                        .frame(width: max(8, proxy.size.width * progress))
                }
            }
            .frame(height: 8)
        }
    }
}

struct AnalyticsNarrativePanel: View {
    let summary: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "What This Means", systemImage: "text.bubble")

                Text(summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct AnalyticsScorePanel: View {
    let score: Int
    let title: String
    let detail: String

    private var progress: Double {
        min(1, max(0, Double(score) / 100))
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Practice Health", systemImage: "gauge.with.dots.needle.67percent")

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 20) {
                        scoreRing

                        scoreCopy

                        Spacer(minLength: 0)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        scoreRing
                        scoreCopy
                    }
                }
            }
        }
    }

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(.quaternary.opacity(0.7), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColor.ink.gradient,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: progress)

            Text("\(score)")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: 112, height: 112)
    }

    private var scoreCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FocusRecommendationPanel: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Next Best Move", systemImage: "sparkles")

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(tint)
                        .frame(width: 42, height: 42)
                        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tint.opacity(0.52), lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.title3.weight(.semibold))

                        Text(detail)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
