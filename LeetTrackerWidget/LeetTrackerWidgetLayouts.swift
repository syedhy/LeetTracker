import SwiftUI

struct SmallWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let status: WidgetStatusPill?

    init(username: String, stats: WidgetStatsSnapshot, status: WidgetStatusPill? = nil) {
        self.username = username
        self.stats = stats
        self.status = status
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.medium) {
                WidgetHeader(style: .compact)

                Spacer(minLength: LTWidgetSpacing.small)

                Text("\(stats.totalSolved)")
                    .font(LTWidgetTypography.primaryNumber)
                    .foregroundStyle(LTWidgetColor.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.xSmall) {
                    Text(username)
                        .font(LTWidgetTypography.compactUser)
                        .foregroundStyle(LTWidgetColor.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)

                    WidgetUpdatedText(date: stats.lastUpdated)
                }

                Spacer(minLength: LTWidgetSpacing.small)

                Text("solved")
                    .font(LTWidgetTypography.compactStatLabel)
                    .foregroundStyle(LTWidgetColor.secondary)
            }

            WidgetDivider()

            WidgetDifficultySummary(stats: stats, style: .compact)

            Spacer(minLength: 0)

            if let status {
                status
            }
        }
        .padding(.horizontal, LTWidgetSpacing.medium)
        .padding(.vertical, LTWidgetSpacing.small)
    }
}

struct MediumWidgetView: View {
    let username: String
    let stats: WidgetStatsSnapshot
    let status: WidgetStatusPill?

    init(username: String, stats: WidgetStatsSnapshot, status: WidgetStatusPill? = nil) {
        self.username = username
        self.stats = stats
        self.status = status
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.large) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
                    WidgetHeader(style: .spacious)

                    VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
                        Text(username)
                            .font(LTWidgetTypography.user)
                            .foregroundStyle(LTWidgetColor.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        WidgetUpdatedText(date: stats.lastUpdated)
                    }
                }

                Spacer(minLength: LTWidgetSpacing.medium)

                VStack(alignment: .trailing, spacing: LTWidgetSpacing.compact) {
                    Text("\(stats.totalSolved)")
                        .font(LTWidgetTypography.mediumNumber)
                        .foregroundStyle(LTWidgetColor.primary)
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("solved")
                        .font(LTWidgetTypography.statLabel)
                        .foregroundStyle(LTWidgetColor.secondary)
                }
            }

            WidgetDivider()

            WidgetDifficultySummary(stats: stats, style: .spacious)

            if let status {
                status
            }
        }
        .padding(.horizontal, LTWidgetSpacing.xLarge)
        .padding(.vertical, LTWidgetSpacing.large)
    }
}
