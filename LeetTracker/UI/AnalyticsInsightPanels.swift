import SwiftUI

struct ProgressSignalsPanel: View {
    let signals: [ProgressSignal]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Progress Signals", systemImage: "waveform.path.ecg")

                VStack(spacing: 12) {
                    ForEach(signals) { signal in
                        ProgressSignalRow(signal: signal)
                    }
                }
            }
        }
    }
}

struct ProgressSignalRow: View {
    let signal: ProgressSignal

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: signal.systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(signal.tint)
                .frame(width: 30, height: 30)
                .background(AppColor.paperWarm.opacity(0.78), in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(signal.tint.opacity(0.5), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(signal.title)
                        .font(.callout.weight(.semibold))

                    Spacer()

                    Text(signal.value)
                        .font(.callout.weight(.semibold).monospacedDigit())
                }

                Text(signal.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct DifficultyBalancePanel: View {
    let stats: LeetCodeStats?
    let rows: [DifficultyDistributionRow]
    let balanceText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Balance", systemImage: "chart.bar.xaxis")

                if stats?.totalSolved ?? 0 > 0 {
                    DifficultyStackedBar(rows: rows)

                    VStack(spacing: 12) {
                        ForEach(rows) { row in
                            DifficultyDistributionDetail(row: row)
                        }
                    }

                    Text(balanceText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    EmptyPanelMessage(
                        title: "No balance yet",
                        message: "Refresh once to compare Easy, Medium, and Hard progress."
                    )
                }
            }
        }
    }
}

struct DifficultyStackedBar: View {
    let rows: [DifficultyDistributionRow]

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 3) {
                ForEach(rows) { row in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(row.tint.gradient)
                        .frame(width: max(row.percentage > 0 ? 8 : 0, proxy.size.width * row.fraction))
                }
            }
        }
        .frame(height: 16)
        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 5))
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(AppColor.line.opacity(0.28), lineWidth: 1)
        }
    }
}

struct DifficultyDistributionDetail: View {
    let row: DifficultyDistributionRow

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(row.tint)
                .frame(width: 9, height: 9)

            Text(row.title)
                .font(.callout.weight(.semibold))

            Spacer()

            Text("\(row.value)")
                .font(.callout.weight(.semibold).monospacedDigit())

            Text("\(row.percentage)%")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 42, alignment: .trailing)
        }
    }
}

struct MilestonePanel: View {
    let title: String
    let subtitle: String
    let rows: [(String, String)]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Milestone", systemImage: "flag.checkered")

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title2.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                VStack(spacing: 10) {
                    ForEach(rows, id: \.0) { row in
                        DetailRow(title: row.0, value: row.1)
                    }
                }
            }
        }
    }
}

struct GoalProjectionPanel: View {
    let currentSolved: Int?
    let targetSolved: Int
    let weeklyTarget: Int
    let completionText: String

    private var remaining: Int {
        max(0, targetSolved - (currentSolved ?? 0))
    }

    private var progress: Double {
        guard let currentSolved, targetSolved > 0 else {
            return 0
        }

        return min(1, Double(currentSolved) / Double(targetSolved))
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Goal Projection", systemImage: "point.topleft.down.curvedto.point.bottomright.up")

                if let currentSolved {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(remaining)")
                                .font(.system(size: 44, weight: .semibold, design: .rounded))
                                .monospacedDigit()

                            Text(remaining == 1 ? "problem left" : "problems left")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(completionText)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        ProjectionTrack(progress: progress)

                        HStack {
                            ProjectionLabel(title: "Now", value: "\(currentSolved)")
                            Spacer()
                            ProjectionLabel(title: "Weekly pace", value: "\(weeklyTarget)")
                            Spacer()
                            ProjectionLabel(title: "Target", value: "\(targetSolved)")
                        }
                    }
                } else {
                    EmptyPanelMessage(
                        title: "No projection yet",
                        message: "Refresh once and set a target to see a simple goal path."
                    )
                }
            }
        }
    }
}

struct ProjectionTrack: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            let clampedProgress = min(1, max(0, progress))
            let dotX = max(9, min(proxy.size.width - 9, proxy.size.width * clampedProgress))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColor.paperWarm.opacity(0.9))
                    .frame(height: 12)

                Capsule()
                    .fill(AppColor.ink)
                    .frame(width: max(12, proxy.size.width * clampedProgress), height: 12)

                Circle()
                    .fill(AppColor.paper)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle()
                            .stroke(AppColor.ink, lineWidth: 3)
                    }
                    .offset(x: dotX - 9)
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: clampedProgress)
            }
        }
        .frame(height: 22)
    }
}

struct ProjectionLabel: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.callout.weight(.semibold).monospacedDigit())
        }
    }
}

struct ProgressSignal: Identifiable {
    var id: String { title }

    let title: String
    let value: String
    let detail: String
    let systemImage: String
    let tint: Color
}

struct DifficultyDistributionRow: Identifiable {
    var id: String { title }

    let title: String
    let value: Int
    let total: Int
    let tint: Color

    var fraction: Double {
        guard total > 0 else {
            return 0
        }

        return Double(value) / Double(total)
    }

    var percentage: Int {
        Int((fraction * 100).rounded())
    }
}
