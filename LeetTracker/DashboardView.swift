import SwiftUI
import WidgetKit

struct DashboardView: View {
    @ObservedObject var viewModel: LeetTrackerViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                header

                dashboardSnapshotSection


            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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

            #if os(iOS)
            VStack(spacing: 20) {
                DashboardHeroBoard(
                    total: viewModel.totalSolvedText,
                    username: viewModel.displayUsername,
                    lastUpdated: viewModel.lastUpdatedText,
                    focusTitle: viewModel.focusRecommendationTitle,
                    focusDetail: viewModel.focusRecommendationDetail
                )
                goalSection
                dataHealthSection
            }
            #else
            HStack(alignment: .top, spacing: 20) {
                DashboardHeroBoard(
                    total: viewModel.totalSolvedText,
                    username: viewModel.displayUsername,
                    lastUpdated: viewModel.lastUpdatedText,
                    focusTitle: viewModel.focusRecommendationTitle,
                    focusDetail: viewModel.focusRecommendationDetail
                )
                .frame(maxWidth: .infinity)

                VStack(spacing: 20) {
                    goalSection
                }
                .frame(minWidth: 300, idealWidth: 340, maxWidth: 380)
            }
            #endif

            #if os(iOS)
            DifficultyDashboardPanel(rows: viewModel.difficultyDistributionRows)
            #endif
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

    private var dataHealthSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Data Health", systemImage: "waveform.path.ecg")

                DetailRow(title: "Cache", value: viewModel.cacheStatusText)
                DetailRow(title: "Auto refresh", value: viewModel.refreshCadenceText)
                DetailRow(title: "Background", value: "WidgetKit + helper")
            }
        }
    }
}
