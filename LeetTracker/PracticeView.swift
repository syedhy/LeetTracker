import SwiftUI

struct PracticeView: View {
    @ObservedObject var viewModel: LeetTrackerViewModel
    @Binding var selectedPracticeMode: PracticeMode

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 32) {
                pageHeader(
                    title: "Practice",
                    subtitle: "Plan the week and tune your goal from one place.",
                    systemImage: "calendar.badge.clock"
                )

                plannerContent
                
                Divider()
                    .padding(.vertical, 8)

                goalsContent
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private var plannerContent: some View {
        VStack(alignment: .leading, spacing: 24) {
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

            #if os(iOS)
            VStack(spacing: 20) {
                PlannerGuidePanel(
                    mixText: viewModel.plannerMixText,
                    targetText: viewModel.plannerGoalDistanceText,
                    paceText: viewModel.plannerPaceText,
                    reminderText: viewModel.plannerReminderTimeText
                )

                ReminderPlanPanel(
                    refreshText: viewModel.refreshCadenceText,
                    remindersEnabled: viewModel.plannerRemindersEnabled,
                    reminderTimeText: viewModel.plannerReminderTimeText,
                    weeklyReviewText: viewModel.plannerWeeklyReviewText,
                    permissionText: viewModel.reminderPermissionText
                )
            }
            #else
            HStack(alignment: .top, spacing: 20) {
                PlannerGuidePanel(
                    mixText: viewModel.plannerMixText,
                    targetText: viewModel.plannerGoalDistanceText,
                    paceText: viewModel.plannerPaceText,
                    reminderText: viewModel.plannerReminderTimeText
                )
                .frame(maxWidth: .infinity)

                ReminderPlanPanel(
                    refreshText: viewModel.refreshCadenceText,
                    remindersEnabled: viewModel.plannerRemindersEnabled,
                    reminderTimeText: viewModel.plannerReminderTimeText,
                    weeklyReviewText: viewModel.plannerWeeklyReviewText,
                    permissionText: viewModel.reminderPermissionText
                )
                .frame(minWidth: 300, idealWidth: 340, maxWidth: 380)
            }
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var analyticsContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            AnalyticsHeroPanel(
                stats: viewModel.statsSnapshot,
                rows: viewModel.difficultyDistributionRows,
                score: viewModel.readinessScore,
                title: viewModel.analyticsHeroTitle,
                detail: viewModel.analyticsHeroDetail,
                targetSolved: viewModel.goalTargetNumber,
                weeklyTarget: viewModel.weeklyTargetNumber,
                completionText: viewModel.estimatedCompletionDateText,
                focusTitle: viewModel.focusRecommendationTitle,
                focusDetail: viewModel.focusRecommendationDetail
            )

            #if os(iOS)
            VStack(spacing: 20) {
                ProgressSignalsPanel(signals: viewModel.progressSignals)

                DifficultyBalancePanel(
                    stats: viewModel.statsSnapshot,
                    rows: viewModel.difficultyDistributionRows,
                    balanceText: viewModel.balanceNarrative
                )
            }
            #else
            HStack(alignment: .top, spacing: 20) {
                ProgressSignalsPanel(signals: viewModel.progressSignals)
                    .frame(maxWidth: .infinity)

                DifficultyBalancePanel(
                    stats: viewModel.statsSnapshot,
                    rows: viewModel.difficultyDistributionRows,
                    balanceText: viewModel.balanceNarrative
                )
                .frame(maxWidth: .infinity)
            }
            #endif

            AnalyticsNarrativePanel(summary: viewModel.analyticsSummary)
        }
    }

    private var goalsContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            #if os(iOS)
            VStack(spacing: 20) {
                goalEditorPanel
                goalPlanPanel
                GoalWeekPreviewPanel(
                    title: viewModel.practicePlanTitle,
                    subtitle: viewModel.practicePlanSubtitle,
                    rows: viewModel.practicePlanRows,
                    nextSession: viewModel.plannerNextSessionText,
                    reminderText: viewModel.remindersEnabled ? viewModel.reminderTimeText : "Off"
                )
            }
            #else
            HStack(alignment: .top, spacing: 20) {
                goalEditorPanel
                    .frame(maxWidth: 500)
            }
            #endif
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

    private var goalPlanPanel: some View {
        GoalPlanPanel(
            title: viewModel.goalPlanTitle,
            subtitle: viewModel.goalPlanSubtitle,
            progress: viewModel.goalProgress,
            detailRows: viewModel.goalDetailRows
        )
    }
}
