import SwiftUI

struct StatsHighlightBoard: View {
    let total: String
    let easy: String
    let medium: String
    let hard: String
    let username: String
    let lastUpdated: String

    var body: some View {
        Panel {
            VStack(spacing: 24) {
                HStack(spacing: 10) {
                    Text(username)
                        .font(.title3.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Circle()
                        .fill(AppColor.ink.opacity(0.42))
                        .frame(width: 5, height: 5)
                    
                    Text(lastUpdated)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                VStack(spacing: 4) {
                    Text(total)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        
                    Text("Total Solved")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                HStack(spacing: 0) {
                    difficultyColumn(title: "Easy", count: easy, color: AppColor.easy)
                    
                    Divider().frame(height: 40)
                    
                    difficultyColumn(title: "Medium", count: medium, color: AppColor.medium)
                    
                    Divider().frame(height: 40)
                    
                    difficultyColumn(title: "Hard", count: hard, color: AppColor.hard)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private func difficultyColumn(title: String, count: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(count)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DashboardCommandCenterPanel: View {
    let goalTitle: String
    let goalDetail: String
    let analyticsTitle: String
    let analyticsDetail: String
    let reminderTitle: String
    let reminderDetail: String
    let plannerTitle: String
    let plannerDetail: String
    let widgetTitle: String
    let widgetDetail: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    SectionHeader(title: "Quick Reads", systemImage: "sparkle.magnifyingglass")

                    Spacer()

                    Text("scan before practice")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }

                #if os(iOS)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    DashboardSignalTile(title: "Target", value: goalTitle, detail: goalDetail, systemImage: "target", tint: AppColor.ink)
                    DashboardSignalTile(title: "Analytics", value: analyticsTitle, detail: analyticsDetail, systemImage: "chart.xyaxis.line", tint: AppColor.ink)
                    DashboardSignalTile(title: "Reminders", value: reminderTitle, detail: reminderDetail, systemImage: "bell.badge", tint: AppColor.medium)
                    DashboardSignalTile(title: "Planner", value: plannerTitle, detail: plannerDetail, systemImage: "calendar.badge.checkmark", tint: AppColor.ink)
                    DashboardSignalTile(title: "Widget", value: widgetTitle, detail: widgetDetail, systemImage: "square.grid.2x2", tint: AppColor.ink)
                }
                #else
                HStack(spacing: 10) {
                    DashboardSignalTile(
                        title: "Target",
                        value: goalTitle,
                        detail: goalDetail,
                        systemImage: "target",
                        tint: AppColor.ink
                    )

                    DashboardSignalTile(
                        title: "Analytics",
                        value: analyticsTitle,
                        detail: analyticsDetail,
                        systemImage: "chart.xyaxis.line",
                        tint: AppColor.ink
                    )

                    DashboardSignalTile(
                        title: "Reminders",
                        value: reminderTitle,
                        detail: reminderDetail,
                        systemImage: "bell.badge",
                        tint: AppColor.medium
                    )

                    DashboardSignalTile(
                        title: "Planner",
                        value: plannerTitle,
                        detail: plannerDetail,
                        systemImage: "calendar.badge.checkmark",
                        tint: AppColor.ink
                    )

                    DashboardSignalTile(
                        title: "Widget",
                        value: widgetTitle,
                        detail: widgetDetail,
                        systemImage: "square.grid.2x2",
                        tint: AppColor.ink
                    )
                }
                #endif
            }
        }
    }
}


struct DashboardSignalTile: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .frame(width: 28, height: 28)
                    .background(AppColor.paper, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(tint.opacity(0.58), lineWidth: 1.4)
                    }

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 102, alignment: .leading)
        .background(tint.opacity(tint == AppColor.ink ? 0.035 : 0.09), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(tint == AppColor.ink ? 0.2 : 0.44), lineWidth: 1.1)
        }
    }
}

struct TotalSolvedCard: View {
    let total: String
    let username: String
    let lastUpdated: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppColor.paper.opacity(0.76))
                        .lineLimit(1)

                    Text(lastUpdated)
                        .font(.caption)
                        .foregroundStyle(AppColor.paper.opacity(0.52))
                }

                Spacer()

                VStack(spacing: 5) {
                    Circle().fill(AppColor.easy)
                    Circle().fill(AppColor.medium)
                    Circle().fill(AppColor.hard)
                }
                .frame(width: 8, height: 30)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(total)
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColor.paper)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("solved")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColor.paper.opacity(0.62))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppColor.ink,
                    Color(red: 0.02, green: 0.02, blue: 0.018)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.line, lineWidth: 1.2)
        }
    }
}

struct DifficultyCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 10, height: 10)

            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(tint.opacity(0.64), lineWidth: 1.2)
        }
    }
}

struct StatusPanel: View {
    let message: String
    let isLoading: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 2)
            } else {
                Image(systemName: "info.circle.fill")
                    .font(.body)
                    .foregroundStyle(AppColor.ink)
                    .padding(.top, 2)
            }

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.75), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColor.line.opacity(0.3), lineWidth: 1)
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)

            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.paperWarm.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.48), lineWidth: 1)
        }
    }
}
