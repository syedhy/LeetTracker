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

                    Text(status?.compactText ?? "\(goalSettings.remaining(after: stats.totalSolved)) left")
                        .font(LTWidgetTypography.caption)
                        .foregroundStyle(status == nil ? LTWidgetColor.secondary : LTWidgetColor.warning)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 0)

                WidgetDifficultySummary(stats: stats, style: .compact)
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

                            WidgetUpdatedText(date: stats.lastUpdated, statusText: status?.text)
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
            }
        }
    }
}


struct StreakSmallWidgetView: View {
    let stats: WidgetStatsSnapshot

    var body: some View {
        WidgetCardContent(size: .streakSmall, alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                VStack(spacing: -2) {
                    Text("\(stats.streakDisplay)")
                        .font(LTWidgetTypography.mediumDisplay)
                        .foregroundStyle(LTWidgetColor.primary)

                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                    Text(streakLabel)
                        .font(LTWidgetTypography.compactLabel)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                }
                .frame(maxWidth: .infinity)

                StreakMascotImage()
                    .frame(width: 70, height: 54)
            }
        }
    }

    private var streakLabel: String { "day streak" }
}



struct StreakMascotImage: View {
    var body: some View {
        Image("StreakMascot")
            .resizable()
            .scaledToFit()
            .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
    }
}
