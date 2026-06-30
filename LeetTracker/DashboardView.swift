import SwiftUI
import WidgetKit

struct DashboardView: View {
    @ObservedObject var viewModel: LeetTrackerViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                header
                
                dashboardSnapshotSection
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            AppIconMark(size: 54, cornerRadius: 15)

            VStack(alignment: .leading, spacing: 4) {
                Text("LeetTracker")
                    #if os(iOS)
                    .font(.title.weight(.bold))
                    #else
                    .font(.largeTitle.weight(.semibold))
                    #endif
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(viewModel.dashboardSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            #if os(macOS)
            Button(action: viewModel.refreshStatsAndReloadWidgets) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)

            StatusPill(
                title: viewModel.isLoading ? "Syncing" : "Ready",
                systemImage: viewModel.isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill",
                tint: AppColor.ink
            )
            #else
            Button(action: viewModel.refreshStatsAndReloadWidgets) {
                Image(systemName: "arrow.clockwise")
                    .font(.body.weight(.bold))
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)
            #endif
        }
    }

    private var dashboardSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "Today’s Snapshot", systemImage: "chart.bar.xaxis")

            StatsHighlightBoard(
                total: viewModel.totalSolvedText,
                easy: viewModel.easySolvedText,
                medium: viewModel.mediumSolvedText,
                hard: viewModel.hardSolvedText,
                username: viewModel.displayUsername,
                lastUpdated: viewModel.lastUpdatedText
            )
            
            goalSection
            
            reminderSection
        }
    }

    private var goalSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Focus", systemImage: "target")

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.focusGoalHeadline)
                        .font(.title.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(viewModel.focusGoalSubtitle)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: viewModel.goalProgress)
                    .tint(AppColor.brand)
            }
        }
    }

    private var reminderSection: some View {
        ReminderPlanPanel(
            refreshText: viewModel.refreshCadenceText,
            remindersEnabled: viewModel.plannerRemindersEnabled,
            reminderTimeText: viewModel.plannerReminderTimeText,
            weeklyReviewText: viewModel.plannerWeeklyReviewText,
            permissionText: viewModel.reminderPermissionText
        )
    }
}
