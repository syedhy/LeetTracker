import SwiftUI

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
