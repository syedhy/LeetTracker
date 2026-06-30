import SwiftUI

struct PracticeView: View {
    @ObservedObject var viewModel: LeetTrackerViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                pageHeader(
                    title: "Practice",
                    subtitle: "Plan the week and tune your goal from one place.",
                    systemImage: "calendar.badge.clock"
                )

                goalEditorPanel
                
                PlannerOverviewPanel(
                    weekTitle: viewModel.plannerWeekTitle,
                    completedCount: viewModel.plannerCompletedCount,
                    sessionCount: viewModel.plannerSessions.count,
                    nextSessionText: viewModel.plannerNextSessionText,
                    progress: viewModel.plannerProgress,
                    resetAction: viewModel.resetPlannerWeek
                )

                WeeklyPlannerBoard(
                    sessions: viewModel.plannerSessions,
                    completedIDs: viewModel.completedPlannerSessionIDs,
                    toggleAction: viewModel.togglePlannerSession
                )
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func pageHeader(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.ink)
                .frame(width: 44, height: 44)
                .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.ink, lineWidth: 1.5)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var goalEditorPanel: some View {
        GoalEditorPanel(
            targetText: $viewModel.goalTargetText,
            weeklyTargetText: $viewModel.weeklyTargetText,
            weeklyEasyTargetText: $viewModel.weeklyEasyTargetText,
            weeklyMediumTargetText: $viewModel.weeklyMediumTargetText,
            weeklyHardTargetText: $viewModel.weeklyHardTargetText,
            remindersEnabled: $viewModel.remindersEnabled,
            reminderTime: $viewModel.reminderTime,
            projectedMixText: viewModel.weeklyPracticeMixText,
            statusText: viewModel.goalStatusMessage,
            saveAction: viewModel.saveGoalSettings
        )
    }
}
