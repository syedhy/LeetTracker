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
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.medium) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
                    WidgetHeader()

                    Text(username)
                        .font(LTWidgetTypography.user)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    WidgetUpdatedText(date: stats.lastUpdated)
                }

                Spacer(minLength: LTWidgetSpacing.small)

                VStack(alignment: .trailing, spacing: LTWidgetSpacing.xSmall) {
                    Text("\(stats.totalSolved)")
                        .font(LTWidgetTypography.primaryNumber)
                        .foregroundStyle(LTWidgetColor.primary)
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("solved")
                        .font(LTWidgetTypography.statLabel)
                        .foregroundStyle(LTWidgetColor.secondary)
                }
            }

            WidgetDivider()

            WidgetDifficultySummary(stats: stats)

            Spacer(minLength: 0)

            if let status {
                status
            }
        }
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
        VStack(alignment: .leading, spacing: LTWidgetSpacing.xLarge) {
            HStack(alignment: .top, spacing: LTWidgetSpacing.xLarge) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
                    WidgetHeader()

                    VStack(alignment: .leading, spacing: LTWidgetSpacing.xSmall) {
                        Text(username)
                            .font(LTWidgetTypography.user)
                            .foregroundStyle(LTWidgetColor.secondary)
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

            WidgetDifficultySummary(stats: stats)

            if let status {
                status
            }
        }
    }
}
