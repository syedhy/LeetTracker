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
