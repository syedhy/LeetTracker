import SwiftUI

struct SmallWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings
    let status: WidgetStatusPill?

    init(username: String, stats: WidgetStatsSnapshot, goalSettings: SharedGoalSettings, status: WidgetStatusPill? = nil) {
        self.username = username
        self.stats = stats
        self.goalSettings = goalSettings
        self.status = status
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.medium) {
                WidgetHeader(isCompact: true)

                Spacer(minLength: LTWidgetSpacing.small)

                Text("\(stats.totalSolved)")
                    .font(LTWidgetTypography.display)
                    .foregroundStyle(LTWidgetColor.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
                Text(username)
                    .font(LTWidgetTypography.compactUser)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text("\(goalSettings.remaining(after: stats.totalSolved)) left to target")
                    .font(LTWidgetTypography.caption)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .lineLimit(1)
            }

            WidgetDifficultySummary(stats: stats, style: .compact)

            if let status {
                status
            }
        }
        .padding(LTWidgetSpacing.smallPadding)
    }
}

struct MediumWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings
    let status: WidgetStatusPill?

    init(username: String, stats: WidgetStatsSnapshot, goalSettings: SharedGoalSettings, status: WidgetStatusPill? = nil) {
        self.username = username
        self.stats = stats
        self.goalSettings = goalSettings
        self.status = status
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.large) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
                    WidgetHeader()

                    HStack(spacing: LTWidgetSpacing.small) {
                        Text(username)
                            .font(LTWidgetTypography.user)
                            .foregroundStyle(LTWidgetColor.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text("·")
                            .font(LTWidgetTypography.label)
                            .foregroundStyle(LTWidgetColor.tertiary)

                        WidgetUpdatedText(date: stats.lastUpdated)
                    }
                }

                Spacer(minLength: LTWidgetSpacing.medium)

                VStack(alignment: .trailing, spacing: LTWidgetSpacing.compact) {
                    Text("\(stats.totalSolved)")
                        .font(LTWidgetTypography.mediumDisplay)
                        .foregroundStyle(LTWidgetColor.primary)
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("solved")
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.secondary)
                }
            }

            WidgetDifficultySummary(stats: stats, style: .spacious)

            HStack(spacing: LTWidgetSpacing.medium) {
                WidgetProgressBar(progress: goalSettings.progress(after: stats.totalSolved), tint: LTWidgetColor.primary)

                Text("\(goalSettings.remaining(after: stats.totalSolved)) left")
                    .font(LTWidgetTypography.caption)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }

            if let status {
                status
            }
        }
        .padding(LTWidgetSpacing.mediumPadding)
    }
}

struct MotivationSmallWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings

    private var difficulty: WidgetDifficulty {
        stats.recommendedDifficulty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(title: "Practice", isCompact: true)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                Text("One clean solve.")
                    .font(LTWidgetTypography.compactHeadline)
                    .foregroundStyle(LTWidgetColor.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)

                Text(difficulty.sessionCopy)
                    .font(LTWidgetTypography.caption)
                    .foregroundStyle(LTWidgetColor.secondary)
                    .lineLimit(2)
            }

            WidgetDifficultyChip(title: difficulty.rawValue, value: goalSettings.remaining(after: stats.totalSolved), tint: difficulty.tint, isCompact: false)
        }
        .padding(LTWidgetSpacing.smallPadding)
    }
}

struct MotivationMediumWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings

    private var difficulty: WidgetDifficulty {
        stats.recommendedDifficulty
    }

    var body: some View {
        HStack(alignment: .center, spacing: LTWidgetSpacing.xxLarge) {
            VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
                WidgetHeader(title: "Practice")

                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    Text("Make the next problem small enough to finish.")
                        .font(LTWidgetTypography.headline)
                        .foregroundStyle(LTWidgetColor.primary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.72)

                    Text("\(username) · \(goalSettings.weeklyMixText) this week")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                }

                WidgetCallout(
                    title: "Next useful move",
                    detail: difficulty.sessionCopy,
                    tint: difficulty.tint
                )
            }

            VStack(alignment: .trailing, spacing: LTWidgetSpacing.medium) {
                Text("\(goalSettings.remaining(after: stats.totalSolved))")
                    .font(LTWidgetTypography.mediumDisplay)
                    .foregroundStyle(LTWidgetColor.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)

                Text("left")
                    .font(LTWidgetTypography.label)
                    .foregroundStyle(LTWidgetColor.secondary)

                WidgetProgressBar(progress: goalSettings.progress(after: stats.totalSolved), tint: difficulty.tint)
                    .frame(width: 88)
            }
        }
        .padding(LTWidgetSpacing.mediumPadding)
    }
}

struct GoalPaceSmallWidgetView: View {
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            WidgetHeader(title: "Goal", isCompact: true)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                Text("\(goalSettings.remaining(after: stats.totalSolved))")
                    .font(LTWidgetTypography.display)
                    .foregroundStyle(LTWidgetColor.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)

                Text("problems left")
                    .font(LTWidgetTypography.label)
                    .foregroundStyle(LTWidgetColor.secondary)
            }

            WidgetProgressBar(progress: goalSettings.progress(after: stats.totalSolved), tint: LTWidgetColor.primary)

            Text("\(goalSettings.weeksRemaining(after: stats.totalSolved)) weeks at \(goalSettings.weeklyTarget)/week")
                .font(LTWidgetTypography.caption)
                .foregroundStyle(LTWidgetColor.tertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .padding(LTWidgetSpacing.smallPadding)
    }
}

struct GoalPaceMediumWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.large) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    WidgetHeader(title: "Goal Pace")

                    Text("\(username) · \(goalSettings.weeklyTarget)/week")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: LTWidgetSpacing.medium)

                VStack(alignment: .trailing, spacing: LTWidgetSpacing.compact) {
                    Text("\(goalSettings.remaining(after: stats.totalSolved))")
                        .font(LTWidgetTypography.mediumDisplay)
                        .foregroundStyle(LTWidgetColor.primary)
                        .contentTransition(.numericText())
                        .lineLimit(1)

                    Text("left")
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.secondary)
                }
            }

            WidgetProgressBar(progress: goalSettings.progress(after: stats.totalSolved), tint: LTWidgetColor.primary)

            HStack(spacing: LTWidgetSpacing.medium) {
                WidgetPaceTile(title: "Target", value: "\(goalSettings.targetSolved)", tint: LTWidgetColor.primary)
                WidgetPaceTile(title: "Mix", value: goalSettings.weeklyMixText, tint: LTWidgetColor.medium)
                WidgetPaceTile(title: "ETA", value: "\(goalSettings.weeksRemaining(after: stats.totalSolved))w", tint: LTWidgetColor.easy)
            }
        }
        .padding(LTWidgetSpacing.mediumPadding)
    }
}

struct WidgetPaceTile: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
            Circle()
                .fill(tint)
                .frame(width: LTWidgetSizing.compactDot, height: LTWidgetSizing.compactDot)

            Text(title)
                .font(LTWidgetTypography.compactLabel)
                .foregroundStyle(LTWidgetColor.tertiary)
                .lineLimit(1)

            Text(value)
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(.horizontal, LTWidgetSpacing.medium)
        .padding(.vertical, LTWidgetSpacing.small)
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: LTWidgetRadius.miniPanel))
        .overlay {
            RoundedRectangle(cornerRadius: LTWidgetRadius.miniPanel)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        }
    }
}
