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
        WidgetCardContent(size: .small) {
            VStack(alignment: .leading, spacing: LTWidgetSpacing.compactContentGap) {
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

                    Text("\(goalSettings.remaining(after: stats.totalSolved)) left")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                WidgetDifficultySummary(stats: stats, style: .compact)

                if let status {
                    status
                }
            }
        }
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
        WidgetCardContent(size: .mediumProgress, alignment: .center) {
            VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
                HStack(alignment: .top, spacing: LTWidgetSpacing.large) {
                    VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
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

                if let status {
                    status
                }
            }
        }
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
        WidgetCardContent(size: .smallTight, alignment: .center) {
            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                WidgetHeader(title: "Practice", isCompact: true, showsCompactTitle: true)

                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    Text(difficulty.sessionCopy)
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }

                Spacer(minLength: 0)

                HStack(spacing: LTWidgetSpacing.small) {
                    WidgetDifficultyChip(title: difficulty.rawValue, value: goalSettings.remaining(after: stats.totalSolved), tint: difficulty.tint, isCompact: false)

                    Text("left")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                }
            }
        }
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
        WidgetCardContent(size: .medium, alignment: .center) {
            HStack(alignment: .center, spacing: LTWidgetSpacing.large) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    WidgetHeader(title: "Practice")

                    VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
                        Text("One small finish")
                            .font(LTWidgetTypography.headline)
                            .foregroundStyle(LTWidgetColor.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text(username)
                            .font(LTWidgetTypography.caption)
                            .foregroundStyle(LTWidgetColor.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    WidgetCallout(
                        title: "Next move",
                        detail: difficulty.sessionCopy,
                        tint: difficulty.tint
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: LTWidgetSpacing.small) {
                    Text("\(goalSettings.remaining(after: stats.totalSolved))")
                        .font(LTWidgetTypography.mediumDisplay)
                        .foregroundStyle(LTWidgetColor.primary)
                        .contentTransition(.numericText())
                        .lineLimit(1)

                    Text("left")
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.secondary)

                    Text(goalSettings.weeklyMixText)
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.tertiary)
                        .lineLimit(1)
                }
                .frame(width: 82, alignment: .trailing)
            }
        }
    }
}

struct GoalPaceSmallWidgetView: View {
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings

    var body: some View {
        WidgetCardContent(size: .smallTight, alignment: .center) {
            VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                WidgetHeader(title: "Goal", isCompact: true, showsCompactTitle: true)

                VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
                    Text("\(goalSettings.remaining(after: stats.totalSolved))")
                        .font(LTWidgetTypography.display)
                        .foregroundStyle(LTWidgetColor.primary)
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text("problems left")
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                HStack(spacing: LTWidgetSpacing.small) {
                    WidgetProgressBar(progress: goalSettings.progress(after: stats.totalSolved), tint: LTWidgetColor.primary)

                    Text("\(goalSettings.weeklyTarget)/wk")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }
            }
        }
    }
}

struct GoalPaceMediumWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings

    var body: some View {
        WidgetCardContent(size: .mediumTight, alignment: .center) {
            HStack(alignment: .center, spacing: LTWidgetSpacing.medium) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
                    WidgetHeader(title: "Goal Pace")

                    Text("\(username) · \(goalSettings.weeklyTarget)/week")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    WidgetProgressBar(progress: goalSettings.progress(after: stats.totalSolved), tint: LTWidgetColor.primary)

                    HStack(spacing: LTWidgetSpacing.small) {
                        WidgetPaceTile(title: "Target", value: "\(goalSettings.targetSolved)", tint: LTWidgetColor.primary)
                        WidgetPaceTile(title: "Mix", value: goalSettings.weeklyMixText, tint: LTWidgetColor.medium)
                        WidgetPaceTile(title: "ETA", value: "\(goalSettings.weeksRemaining(after: stats.totalSolved))w", tint: LTWidgetColor.easy)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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
                .frame(width: 78, alignment: .trailing)
            }
        }
    }
}

struct WidgetPaceTile: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
            Text(title)
                .font(LTWidgetTypography.compactLabel)
                .foregroundStyle(LTWidgetColor.tertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(value)
                .font(LTWidgetTypography.caption)
                .foregroundStyle(LTWidgetColor.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .padding(.horizontal, LTWidgetSpacing.compact)
        .padding(.vertical, LTWidgetSpacing.compact)
        .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: LTWidgetRadius.miniPanel))
        .overlay {
            RoundedRectangle(cornerRadius: LTWidgetRadius.miniPanel)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        }
    }
}
