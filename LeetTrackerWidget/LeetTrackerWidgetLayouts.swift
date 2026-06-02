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
        VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
            WidgetHeader()

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: LTWidgetSpacing.compact) {
                Text("\(stats.totalSolved)")
                    .font(LTWidgetTypography.primaryNumber)
                    .foregroundStyle(LTWidgetColor.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                HStack(spacing: LTWidgetSpacing.small) {
                    Text("solved")
                        .font(LTWidgetTypography.user)
                        .foregroundStyle(LTWidgetColor.secondary)

                    Text(username)
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            WidgetDifficultySummary(stats: stats)

            if let status {
                status
            } else {
                WidgetUpdatedText(date: stats.lastUpdated)
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
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
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

            WidgetDifficultySummary(stats: stats)

            if let status {
                status
            }
        }
    }
}
