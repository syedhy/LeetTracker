import Foundation
import SwiftUI
import WidgetKit

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case practice = "Practice"
    case widgets = "Widgets"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            return "rectangle.3.group"
        case .practice:
            return "calendar.badge.checkmark"
        case .widgets:
            return "square.grid.2x2"
        case .settings:
            return "gearshape"
        }
    }
}

enum PracticeMode: String, CaseIterable, Identifiable {
    case plan = "Plan"
    case analytics = "Analytics"
    case goals = "Goals"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .plan:
            return "calendar.badge.checkmark"
        case .analytics:
            return "chart.xyaxis.line"
        case .goals:
            return "target"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = LeetTrackerViewModel()
    @State private var selectedSection = AppSection.dashboard
    @State private var selectedPracticeMode = PracticeMode.plan
    @State private var isSidebarVisible = true

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppSurfaceBackground()

            HStack(spacing: 0) {
                if isSidebarVisible {
                    AppSidebar(
                        selectedSection: $selectedSection,
                        isSidebarVisible: $isSidebarVisible
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))

                    Divider()
                }

                mainWorkspace
            }

            if !isSidebarVisible {
                FloatingSidebarToggle {
                    withAnimation(.snappy(duration: 0.18)) {
                        isSidebarVisible = true
                    }
                }
                .padding(18)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.18), value: isSidebarVisible)
        .frame(minWidth: 780, idealWidth: 1120, minHeight: 620)
        .onAppear {
            viewModel.loadSavedState()
        }
    }

    private var mainWorkspace: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 26) {
                selectedContent
                    .sectionEntrance(trigger: "\(selectedSection.rawValue)-\(selectedPracticeMode.rawValue)")
            }
            .padding(.leading, isSidebarVisible ? 30 : 82)
            .padding(.trailing, 30)
            .padding(.vertical, 30)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.visible)
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .dashboard:
            dashboard
        case .practice:
            practicePage
        case .widgets:
            widgetsPage
        case .settings:
            settingsPage
        }
    }

    private var dashboard: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            dashboardSnapshotSection

            DashboardCommandCenterPanel(
                goalTitle: viewModel.goalDashboardSummaryTitle,
                goalDetail: viewModel.goalDashboardSummaryDetail,
                analyticsTitle: viewModel.analyticsDashboardSummaryTitle,
                analyticsDetail: viewModel.analyticsDashboardSummaryDetail,
                reminderTitle: viewModel.reminderDashboardSummaryTitle,
                reminderDetail: viewModel.reminderDashboardSummaryDetail,
                plannerTitle: viewModel.plannerDashboardSummaryTitle,
                plannerDetail: viewModel.plannerDashboardSummaryDetail,
                widgetTitle: viewModel.widgetDashboardSummaryTitle,
                widgetDetail: viewModel.widgetDashboardSummaryDetail
            )

            WeeklyPlannerBoard(
                sessions: viewModel.plannerSessions,
                completedIDs: viewModel.completedPlannerSessionIDs,
                toggleAction: viewModel.togglePlannerSession
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dashboardSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "Today’s Snapshot", systemImage: "chart.bar.xaxis")

            ViewThatFits(in: .horizontal) {
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
                        dataHealthSection
                    }
                    .frame(minWidth: 300, idealWidth: 340, maxWidth: 380)
                }

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
            }
        }
    }

    private var practicePage: some View {
        VStack(alignment: .leading, spacing: 24) {
            pageHeader(
                title: "Practice",
                subtitle: "Plan the week, read the signals, and tune the goal from one place.",
                systemImage: selectedPracticeMode.systemImage
            )

            PracticeModePicker(selectedMode: $selectedPracticeMode)

            switch selectedPracticeMode {
            case .plan:
                plannerContent
            case .analytics:
                analyticsContent
            case .goals:
                goalsContent
            }
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

            ViewThatFits(in: .horizontal) {
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

                VStack(spacing: 20) {
                    ProgressSignalsPanel(signals: viewModel.progressSignals)

                    DifficultyBalancePanel(
                        stats: viewModel.statsSnapshot,
                        rows: viewModel.difficultyDistributionRows,
                        balanceText: viewModel.balanceNarrative
                    )
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    GoalProjectionPanel(
                        currentSolved: viewModel.currentSolvedValue,
                        targetSolved: viewModel.goalTargetNumber,
                        weeklyTarget: viewModel.weeklyTargetNumber,
                        completionText: viewModel.estimatedCompletionDateText
                    )
                    .frame(maxWidth: .infinity)

                    AnalyticsNarrativePanel(summary: viewModel.analyticsSummary)
                        .frame(maxWidth: .infinity)
                }

                VStack(spacing: 20) {
                    GoalProjectionPanel(
                        currentSolved: viewModel.currentSolvedValue,
                        targetSolved: viewModel.goalTargetNumber,
                        weeklyTarget: viewModel.weeklyTargetNumber,
                        completionText: viewModel.estimatedCompletionDateText
                    )

                    AnalyticsNarrativePanel(summary: viewModel.analyticsSummary)
                }
            }
        }
    }

    private var goalsContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
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
                    .frame(minWidth: 340, idealWidth: 390, maxWidth: 430)

                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.goalProgress,
                        detailRows: viewModel.goalDetailRows
                    )
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: 20) {
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

                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.goalProgress,
                        detailRows: viewModel.goalDetailRows
                    )
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    PracticePlanPanel(
                        title: viewModel.practicePlanTitle,
                        subtitle: viewModel.practicePlanSubtitle,
                        rows: viewModel.practicePlanRows,
                        tint: viewModel.focusRecommendationTint
                    )
                    .frame(maxWidth: .infinity)

                    ReminderPlanPanel(
                        refreshText: viewModel.refreshCadenceText,
                        remindersEnabled: viewModel.remindersEnabled,
                        reminderTimeText: viewModel.reminderTimeText,
                        weeklyReviewText: viewModel.weeklyReviewReminderText,
                        permissionText: viewModel.reminderPermissionText
                    )
                    .frame(minWidth: 300, idealWidth: 340, maxWidth: 380)
                }

                VStack(spacing: 20) {
                    PracticePlanPanel(
                        title: viewModel.practicePlanTitle,
                        subtitle: viewModel.practicePlanSubtitle,
                        rows: viewModel.practicePlanRows,
                        tint: viewModel.focusRecommendationTint
                    )

                    ReminderPlanPanel(
                        refreshText: viewModel.refreshCadenceText,
                        remindersEnabled: viewModel.remindersEnabled,
                        reminderTimeText: viewModel.reminderTimeText,
                        weeklyReviewText: viewModel.weeklyReviewReminderText,
                        permissionText: viewModel.reminderPermissionText
                    )
                }
            }
        }
    }

    private var widgetsPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            pageHeader(
                title: "Widgets",
                subtitle: "The desktop should show useful progress without opening the app.",
                systemImage: "square.grid.2x2"
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    WidgetIdeaPanel(title: "Progress", detail: "Current solved count, difficulty mix, and last updated time.", systemImage: "checkmark.seal.fill", tint: AppColor.ink)
                    WidgetIdeaPanel(title: "Motivation", detail: "A daily nudge that turns the next small practice block into a visible desktop prompt.", systemImage: "quote.bubble.fill", tint: AppColor.medium)
                    WidgetIdeaPanel(title: "Goal Pace", detail: "Milestone progress, remaining problems, and whether the weekly target is still on track.", systemImage: "speedometer", tint: AppColor.ink)
                }

                VStack(spacing: 20) {
                    WidgetIdeaPanel(title: "Progress", detail: "Current solved count, difficulty mix, and last updated time.", systemImage: "checkmark.seal.fill", tint: AppColor.ink)
                    WidgetIdeaPanel(title: "Motivation", detail: "A daily nudge that turns the next small practice block into a visible desktop prompt.", systemImage: "quote.bubble.fill", tint: AppColor.medium)
                    WidgetIdeaPanel(title: "Goal Pace", detail: "Milestone progress, remaining problems, and whether the weekly target is still on track.", systemImage: "speedometer", tint: AppColor.ink)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

            ViewThatFits(in: .horizontal) {
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var settingsPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            pageHeader(
                title: "Settings",
                subtitle: "Profile, refresh, cache, and local data controls.",
                systemImage: "gearshape"
            )

            setupSection
            dataHealthSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            AppIconMark()

            VStack(alignment: .leading, spacing: 4) {
                Text("LeetTracker")
                    .font(.largeTitle.weight(.semibold))

                Text(viewModel.dashboardSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: refreshStats) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)

            StatusPill(
                title: viewModel.isLoading ? "Syncing" : "Ready",
                systemImage: viewModel.isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill",
                tint: AppColor.ink
            )
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "Today’s Snapshot", systemImage: "chart.bar.xaxis")

            DashboardHeroBoard(
                total: viewModel.totalSolvedText,
                username: viewModel.displayUsername,
                lastUpdated: viewModel.lastUpdatedText,
                focusTitle: viewModel.focusRecommendationTitle,
                focusDetail: viewModel.focusRecommendationDetail
            )
        }
    }

    private var setupSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Profile", systemImage: "person.crop.circle")

                VStack(alignment: .leading, spacing: 8) {
                    Text("LeetCode Username")
                        .font(.headline)

                    TextField("username", text: $viewModel.username)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(.horizontal, 13)
                        .frame(height: 38)
                        .background(AppColor.paperWarm.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColor.line.opacity(0.5), lineWidth: 1)
                        }
                        .onSubmit(saveUsername)
                }

                HStack(spacing: 10) {
                    Button(action: saveUsername) {
                        Label("Save", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .keyboardShortcut(.defaultAction)
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)

                    Button(action: refreshStats) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)
                }

                Divider()

                StatusPanel(message: viewModel.statusMessage, isLoading: viewModel.isLoading)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var analyticsSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Analytics", systemImage: "chart.line.uptrend.xyaxis")

                HStack(spacing: 12) {
                    InsightCard(title: "Difficulty Mix", value: viewModel.difficultyMixText, tint: AppColor.brand)
                    InsightCard(title: "Goal Pace", value: viewModel.estimatedWeeksText, tint: AppColor.ink)
                    InsightCard(title: "Remaining", value: viewModel.goalRemainingText, tint: AppColor.ink)
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    DetailRow(title: "Recommendation", value: viewModel.focusRecommendationTitle)
                    DetailRow(title: "Target", value: viewModel.goalTargetDisplayText)
                    DetailRow(title: "Source", value: "Public profile")
                    DetailRow(title: "Widget", value: viewModel.refreshCadenceText)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var planningSnapshot: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 20) {
                DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)

                VStack(spacing: 20) {
                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.goalProgress,
                        detailRows: viewModel.goalDetailRows
                    )

                    PracticePlanPanel(
                        title: viewModel.practicePlanTitle,
                        subtitle: viewModel.practicePlanSubtitle,
                        rows: viewModel.practicePlanRows,
                        tint: viewModel.focusRecommendationTint
                    )
                }
            }

            VStack(spacing: 20) {
                DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                GoalPlanPanel(
                    title: viewModel.goalPlanTitle,
                    subtitle: viewModel.goalPlanSubtitle,
                    progress: viewModel.goalProgress,
                    detailRows: viewModel.goalDetailRows
                )
                PracticePlanPanel(
                    title: viewModel.practicePlanTitle,
                    subtitle: viewModel.practicePlanSubtitle,
                    rows: viewModel.practicePlanRows,
                    tint: viewModel.focusRecommendationTint
                )
            }
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
                DetailRow(title: "Background", value: "Helper ready")
            }
        }
    }

    private func saveUsername() {
        fetchStatsAndRequestWidgetReload()
    }

    private func refreshStats() {
        fetchStatsAndRequestWidgetReload()
    }

    private func fetchStatsAndRequestWidgetReload() {
        Task {
            if await viewModel.refreshStats() {
                let requestedAt = Date()
                requestWidgetReload()
                viewModel.markWidgetReloadRequested(at: requestedAt)
            }
        }
    }

    private func requestWidgetReload() {
        WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.kind)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    ContentView()
}

@MainActor
private final class LeetTrackerViewModel: ObservableObject {
    @Published var username = ""
    @Published var goalTargetText = ""
    @Published var weeklyTargetText = ""
    @Published var weeklyEasyTargetText = ""
    @Published var weeklyMediumTargetText = ""
    @Published var weeklyHardTargetText = ""
    @Published var remindersEnabled = false
    @Published var reminderTime = Date()
    @Published private(set) var stats: LeetCodeStats?
    @Published private(set) var statusMessage = "Enter a LeetCode username to prepare tracking."
    @Published private(set) var goalStatusMessage = "Goal settings are ready."
    @Published private(set) var reminderPermissionText = "Notifications not requested yet."
    @Published private(set) var completedPlannerSessionIDs: Set<String> = []
    @Published private(set) var isLoading = false

    private let client: LeetCodeClient
    private let sharedStore: SharedLeetTrackerStore
    private let reminderScheduler: ReminderScheduler
    private let plannerDefaults: UserDefaults
    private var savedGoalSettings = SharedGoalSettings.default
    private var hasSavedGoalSettings = false

    init(
        client: LeetCodeClient = LeetCodeClient(),
        sharedStore: SharedLeetTrackerStore = SharedLeetTrackerStore(),
        reminderScheduler: ReminderScheduler = ReminderScheduler(),
        plannerDefaults: UserDefaults = .standard
    ) {
        self.client = client
        self.sharedStore = sharedStore
        self.reminderScheduler = reminderScheduler
        self.plannerDefaults = plannerDefaults
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var totalSolvedText: String {
        statText(stats?.totalSolved)
    }

    var easySolvedText: String {
        statText(stats?.easySolved)
    }

    var mediumSolvedText: String {
        statText(stats?.mediumSolved)
    }

    var hardSolvedText: String {
        statText(stats?.hardSolved)
    }

    var displayUsername: String {
        if let username = stats?.username, !username.isEmpty {
            return username
        }

        if !trimmedUsername.isEmpty {
            return trimmedUsername
        }

        return "No profile selected"
    }

    var lastUpdatedText: String {
        guard let lastUpdated = stats?.lastUpdated else {
            return "Not synced yet"
        }

        return "Updated \(formatted(lastUpdated))"
    }

    var dashboardSubtitle: String {
        guard let stats else {
            return "Public LeetCode progress dashboard"
        }

        return "\(stats.username) · \(stats.totalSolved) solved"
    }

    var goalDashboardSummaryTitle: String {
        guard stats != nil else {
            return "Goal"
        }

        return "\(goalRemainingText) left"
    }

    var goalDashboardSummaryDetail: String {
        guard stats != nil else {
            return "Refresh a profile, then set a target."
        }

        return "Target \(goalTargetValue) · \(weeklyTargetValue) per week"
    }

    var analyticsDashboardSummaryTitle: String {
        difficultyMixText
    }

    var analyticsDashboardSummaryDetail: String {
        guard stats != nil else {
            return "Analytics appear after a refresh."
        }

        return "\(readinessTitle) · \(focusRecommendationTitle)"
    }

    var reminderDashboardSummaryTitle: String {
        remindersEnabled ? reminderTimeText : "Off"
    }

    var reminderDashboardSummaryDetail: String {
        remindersEnabled ? "Daily reminder · weekly review" : "No practice reminders scheduled"
    }

    var plannerDashboardSummaryTitle: String {
        "\(plannerCompletedCount)/\(plannerSessions.count) sessions"
    }

    var plannerDashboardSummaryDetail: String {
        guard let nextSession = plannerSessions.first(where: { !completedPlannerSessionIDs.contains($0.id) }) else {
            return plannerSessions.isEmpty ? "Set a weekly mix to generate the board" : "Weekly board complete"
        }

        return "Next \(nextSession.dayText) · \(nextSession.difficulty.rawValue)"
    }

    var widgetDashboardSummaryTitle: String {
        refreshCadenceText
    }

    var widgetDashboardSummaryDetail: String {
        "Auto refresh when macOS allows it"
    }

    var difficultyMixText: String {
        guard let stats, stats.totalSolved > 0 else {
            return "--"
        }

        let mediumHard = stats.mediumSolved + stats.hardSolved
        let percentage = Int((Double(mediumHard) / Double(stats.totalSolved) * 100).rounded())
        return "\(percentage)% M/H"
    }

    var nextMilestoneText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        return "\(nextMilestone(after: totalSolved)) solved"
    }

    var goalTargetDisplayText: String {
        "\(goalTargetValue) solved"
    }

    var focusGoalHeadline: String {
        guard stats != nil else {
            return "Set a target"
        }

        return "Target \(goalTargetValue)"
    }

    var focusGoalSubtitle: String {
        guard let stats else {
            return "Refresh a profile to start goal tracking."
        }

        return "\(stats.totalSolved) solved now · \(goalRemainingText) remaining"
    }

    var goalRemainingText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        return "\(max(0, goalTargetValue - totalSolved))"
    }

    var goalProgress: Double {
        guard let totalSolved = stats?.totalSolved else {
            return 0
        }

        guard goalTargetValue > 0 else {
            return 0
        }

        return min(1, Double(totalSolved) / Double(goalTargetValue))
    }

    var estimatedWeeksText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        let remaining = max(0, goalTargetValue - totalSolved)

        guard remaining > 0 else {
            return "Done"
        }

        let weeks = Int(ceil(Double(remaining) / Double(max(1, weeklyTargetValue))))
        return weeks == 1 ? "1 week" : "\(weeks) weeks"
    }

    var estimatedCompletionDateText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        let remaining = max(0, goalTargetValue - totalSolved)

        guard remaining > 0 else {
            return "Reached"
        }

        let weeks = Int(ceil(Double(remaining) / Double(max(1, weeklyTargetValue))))
        let days = max(1, weeks * 7)
        let completionDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return DateFormatter.localizedString(from: completionDate, dateStyle: .medium, timeStyle: .none)
    }

    var dailyPaceText: String {
        if weeklyTargetValue >= 7 {
            let perDay = Double(weeklyTargetValue) / 7
            return String(format: "%.1f per day", perDay)
        }

        let spacing = Int(ceil(7.0 / Double(max(1, weeklyTargetValue))))
        return spacing <= 1 ? "1 per day" : "1 every \(spacing) days"
    }

    var weeklyPracticeMixText: String {
        let easy = weeklyEasyTargetValue
        let medium = weeklyMediumTargetValue
        let hard = weeklyHardTargetValue

        if hard > 0 {
            return "\(easy) Easy, \(medium) Medium, \(hard) Hard"
        }

        return "\(easy) Easy, \(medium) Medium"
    }

    var plannerSessions: [PlannerSession] {
        let targets = difficultyTargets(from: savedGoalSettings)
        return WeeklyPlannerFactory.makeSessions(
            easy: targets.easy,
            medium: targets.medium,
            hard: targets.hard
        )
    }

    var plannerMixText: String {
        let targets = difficultyTargets(from: savedGoalSettings)
        return difficultyMixText(easy: targets.easy, medium: targets.medium, hard: targets.hard)
    }

    var plannerPaceText: String {
        paceText(for: savedGoalSettings.weeklyTarget)
    }

    var plannerRemindersEnabled: Bool {
        savedGoalSettings.remindersEnabled
    }

    var plannerReminderTimeText: String {
        guard savedGoalSettings.remindersEnabled else {
            return "Off"
        }

        let date = reminderDate(hour: savedGoalSettings.reminderHour, minute: savedGoalSettings.reminderMinute)
        return formattedTime(date)
    }

    var plannerWeeklyReviewText: String {
        savedGoalSettings.remindersEnabled ? "Sundays at \(plannerReminderTimeText)" : "Off"
    }

    var plannerGoalDistanceText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "Refresh profile"
        }

        let remaining = max(0, savedGoalSettings.targetSolved - totalSolved)
        return remaining == 0 ? "Goal reached" : "\(remaining) problems left"
    }

    var plannerWeekTitle: String {
        WeeklyPlannerFactory.weekTitle()
    }

    var plannerCompletedCount: Int {
        plannerSessions.filter { completedPlannerSessionIDs.contains($0.id) }.count
    }

    var plannerProgress: Double {
        guard !plannerSessions.isEmpty else {
            return 0
        }

        return Double(plannerCompletedCount) / Double(plannerSessions.count)
    }

    var plannerNextSessionText: String {
        guard let nextSession = plannerSessions.first(where: { !completedPlannerSessionIDs.contains($0.id) }) else {
            return plannerSessions.isEmpty
                ? "Set weekly difficulty targets in Goals to generate your practice board."
                : "This week's board is complete. Review the goal before planning the next week."
        }

        return "Next: \(nextSession.dayText) · \(nextSession.difficulty.sessionTitle) · \(nextSession.difficulty.rawValue)"
    }

    var analyticsHeroTitle: String {
        guard let stats, stats.totalSolved > 0 else {
            return "Refresh once to draw your practice map"
        }

        return "\(stats.totalSolved) solved · \(readinessTitle)"
    }

    var analyticsHeroDetail: String {
        guard stats != nil else {
            return "LeetTracker will turn public solved counts and your local goals into readable signals without pretending to know private activity."
        }

        return "This is a local practice-health view: difficulty balance, target distance, and the next useful move."
    }

    var planIntensityText: String {
        switch weeklyTargetValue {
        case 1...3:
            return "Light"
        case 4...7:
            return "Steady"
        case 8...14:
            return "Focused"
        default:
            return "Aggressive"
        }
    }

    var cacheStatusText: String {
        guard let lastUpdated = stats?.lastUpdated else {
            return "Empty"
        }

        return formatted(lastUpdated)
    }

    var refreshCadenceText: String {
        let minutes = Int(LeetTrackerWidgetConfiguration.refreshInterval / 60)
        return "Every \(minutes) min"
    }

    var statsSnapshot: LeetCodeStats? {
        stats
    }

    var currentSolvedValue: Int? {
        stats?.totalSolved
    }

    var goalTargetNumber: Int {
        goalTargetValue
    }

    var weeklyTargetNumber: Int {
        weeklyTargetValue
    }

    var difficultyDistributionRows: [DifficultyDistributionRow] {
        let total = stats?.totalSolved ?? 0

        return [
            DifficultyDistributionRow(title: "Easy", value: stats?.easySolved ?? 0, total: total, tint: AppColor.easy),
            DifficultyDistributionRow(title: "Medium", value: stats?.mediumSolved ?? 0, total: total, tint: AppColor.medium),
            DifficultyDistributionRow(title: "Hard", value: stats?.hardSolved ?? 0, total: total, tint: AppColor.hard)
        ]
    }

    var balanceNarrative: String {
        guard let stats, stats.totalSolved > 0 else {
            return "Balance appears after the first successful refresh."
        }

        let mediumHard = stats.mediumSolved + stats.hardSolved
        let mediumHardPercentage = Int((Double(mediumHard) / Double(stats.totalSolved) * 100).rounded())

        if stats.hardSolved == 0, stats.totalSolved >= 20 {
            return "Your volume is growing, but Hard is still empty. Add one carefully reviewed Hard problem when you have enough time to study the pattern."
        }

        if mediumHardPercentage < 45 {
            return "Your solved count is still easy-heavy. That is fine for warmups, but the next useful improvement is more Medium practice."
        }

        if mediumHardPercentage >= 65 {
            return "Your mix is challenge-heavy. Keep Medium as the default and use Easy problems only to stay warm."
        }

        return "Your difficulty mix is balanced enough for steady practice. Keep the weekly target consistent and avoid overcorrecting."
    }

    var progressSignals: [ProgressSignal] {
        guard let stats, stats.totalSolved > 0 else {
            return [
                ProgressSignal(
                    title: "Profile",
                    value: "Empty",
                    detail: "Save a username and refresh once to unlock analytics.",
                    systemImage: "person.crop.circle.badge.questionmark",
                    tint: AppColor.ink
                ),
                ProgressSignal(
                    title: "Data source",
                    value: "Public",
                    detail: "LeetTracker only uses public profile-level solved counts.",
                    systemImage: "lock.open",
                    tint: AppColor.ink
                )
            ]
        }

        let remaining = max(0, goalTargetValue - stats.totalSolved)
        let mediumHard = stats.mediumSolved + stats.hardSolved
        let mediumHardPercentage = Int((Double(mediumHard) / Double(stats.totalSolved) * 100).rounded())

        return [
            ProgressSignal(
                title: "Difficulty balance",
                value: "\(mediumHardPercentage)% M/H",
                detail: "Useful practice progress usually comes from raising this without ignoring warmups.",
                systemImage: "chart.bar.fill",
                tint: focusRecommendationTint
            ),
            ProgressSignal(
                title: "Goal distance",
                value: remaining == 0 ? "Reached" : "\(remaining) left",
                detail: remaining == 0 ? "Set a new target to keep the next milestone visible." : "\(estimatedWeeksText) at your saved weekly pace.",
                systemImage: "target",
                tint: remaining == 0 ? AppColor.easy : AppColor.ink
            ),
            ProgressSignal(
                title: "Practice rhythm",
                value: dailyPaceText,
                detail: "\(weeklyPracticeMixText) keeps the week concrete instead of vague.",
                systemImage: "calendar.badge.clock",
                tint: AppColor.medium
            ),
            ProgressSignal(
                title: "Next milestone",
                value: nextMilestoneText,
                detail: "A small visible milestone is easier to finish than a huge abstract target.",
                systemImage: "flag.checkered",
                tint: AppColor.ink
            )
        ]
    }

    var milestoneTitle: String {
        guard let stats else {
            return "Refresh to find the next milestone"
        }

        return "\(stats.totalSolved) → \(nextMilestone(after: stats.totalSolved)) solved"
    }

    var milestoneSubtitle: String {
        guard let stats else {
            return "LeetTracker will use your current solved count to suggest the next small visible target."
        }

        let next = nextMilestone(after: stats.totalSolved)
        let remaining = max(0, next - stats.totalSolved)

        if remaining == 1 {
            return "One problem closes the next milestone. Make it intentional."
        }

        return "\(remaining) problems closes the next milestone. Keep the scope small and finishable."
    }

    var milestoneRows: [(String, String)] {
        guard let stats else {
            return [
                ("Current", "--"),
                ("Next", "--"),
                ("Milestone gap", "--")
            ]
        }

        let next = nextMilestone(after: stats.totalSolved)
        let remaining = max(0, next - stats.totalSolved)

        return [
            ("Current", "\(stats.totalSolved) solved"),
            ("Next", "\(next) solved"),
            ("Milestone gap", remaining == 1 ? "1 problem" : "\(remaining) problems"),
            ("Suggested mix", weeklyPracticeMixText)
        ]
    }

    var goalDetailRows: [(String, String)] {
        [
            ("Target", goalTargetDisplayText),
            ("Remaining", goalRemainingText),
            ("Weekly pace", "\(weeklyTargetValue) problems"),
            ("ETA", estimatedWeeksText),
            ("Finish by", estimatedCompletionDateText)
        ]
    }

    var practicePlanTitle: String {
        guard stats != nil else {
            return "Load a profile first"
        }

        return "\(weeklyTargetValue) problem\(weeklyTargetValue == 1 ? "" : "s") this week"
    }

    var practicePlanSubtitle: String {
        guard let stats, stats.totalSolved > 0 else {
            return "After your first refresh, the plan will turn your goal into a weekly practice target."
        }

        if max(0, goalTargetValue - stats.totalSolved) == 0 {
            return "Your active target is complete. Set the next milestone to keep momentum visible."
        }

        return "\(dailyPaceText). \(focusRecommendationDetail)"
    }

    var practicePlanRows: [(String, String)] {
        [
            ("Daily pace", dailyPaceText),
            ("Weekly mix", weeklyPracticeMixText),
            ("Finish date", estimatedCompletionDateText),
            ("Intensity", planIntensityText)
        ]
    }

    var readinessScore: Int {
        guard let stats, stats.totalSolved > 0 else {
            return 0
        }

        let goalComponent = min(45, Int((goalProgress * 45).rounded()))
        let mediumHardRatio = Double(stats.mediumSolved + stats.hardSolved) / Double(stats.totalSolved)
        let balanceComponent = min(35, Int((mediumHardRatio * 70).rounded()))
        let hardComponent = min(20, stats.hardSolved * 2)

        return min(100, max(0, goalComponent + balanceComponent + hardComponent))
    }

    var readinessTitle: String {
        switch readinessScore {
        case 80...:
            return "Strong momentum"
        case 55..<80:
            return "Solid base"
        case 25..<55:
            return "Building up"
        default:
            return stats == nil ? "Waiting for data" : "Early stage"
        }
    }

    var readinessDetail: String {
        guard let stats, stats.totalSolved > 0 else {
            return "Refresh a profile once to calculate a local practice score from solved count, goal progress, and difficulty balance."
        }

        return "\(difficultyMixText) are Medium or Hard. This is a local practice signal, not an official readiness score."
    }

    var focusRecommendationTitle: String {
        guard let stats, stats.totalSolved > 0 else {
            return "Load profile"
        }

        let mediumHard = stats.mediumSolved + stats.hardSolved
        let mediumHardRatio = Double(mediumHard) / Double(stats.totalSolved)

        if stats.hardSolved == 0, stats.totalSolved >= 20 {
            return "Add one Hard"
        }

        if mediumHardRatio < 0.45 {
            return "Lean into Medium"
        }

        if max(0, goalTargetValue - stats.totalSolved) <= weeklyTargetValue {
            return "Finish the goal"
        }

        return "Keep balance"
    }

    var focusRecommendationDetail: String {
        guard let stats, stats.totalSolved > 0 else {
            return "Save your username and refresh to get a useful next action."
        }

        switch focusRecommendationTitle {
        case "Add one Hard":
            return "You have enough volume to try a carefully chosen Hard problem and learn from the pattern."
        case "Lean into Medium":
            return "Your solved mix is still easy-heavy. Medium problems should drive the next practice block."
        case "Finish the goal":
            return "You are within this week's pace. A short push can close the target cleanly."
        default:
            return "Keep Easy warmups short, make Medium the default, and use Hard problems deliberately."
        }
    }

    var focusRecommendationTint: Color {
        switch focusRecommendationTitle {
        case "Add one Hard":
            return AppColor.hard
        case "Lean into Medium":
            return AppColor.medium
        case "Finish the goal":
            return AppColor.easy
        default:
            return AppColor.brand
        }
    }

    var analyticsSummary: String {
        guard let stats, stats.totalSolved > 0 else {
            return "No profile data is loaded yet. Save your LeetCode username and refresh once so LeetTracker can turn your public solved counts into readable progress signals."
        }

        let mediumHard = stats.mediumSolved + stats.hardSolved
        let mediumHardPercentage = Int((Double(mediumHard) / Double(stats.totalSolved) * 100).rounded())
        let remaining = max(0, goalTargetValue - stats.totalSolved)

        return "Based only on public solved counts, you have solved \(stats.totalSolved) problems and \(mediumHardPercentage)% are Medium or Hard. Treat this as a practice-health signal, not an official ranking or readiness score. Your current target is \(goalTargetValue) solved, so \(remaining) more problem\(remaining == 1 ? "" : "s") gets you there at about \(estimatedWeeksText)."
    }

    var goalPlanTitle: String {
        guard stats != nil else {
            return "Set your first goal"
        }

        return "Reach \(goalTargetValue) solved"
    }

    var goalPlanSubtitle: String {
        guard let totalSolved = stats?.totalSolved else {
            return "After a profile refresh, LeetTracker will suggest a simple milestone goal from your current solved count."
        }

        let remaining = max(0, goalTargetValue - totalSolved)

        if remaining == 0 {
            return "Goal reached. Set the next target when you are ready."
        }

        return "\(remaining) problem\(remaining == 1 ? "" : "s") left at \(weeklyTargetValue) per week. Keep the goal small, measurable, and visible."
    }

    var reminderTimeText: String {
        formattedTime(reminderTime)
    }

    var weeklyReviewReminderText: String {
        remindersEnabled ? "Sundays at \(reminderTimeText)" : "Off"
    }

    func loadSavedState() {
        let snapshot = sharedStore.snapshot
        hasSavedGoalSettings = snapshot.hasGoalSettings
        applyGoalSettings(
            snapshot.hasGoalSettings ? snapshot.goalSettings : suggestedGoalSettings(currentTotal: snapshot.cachedStats?.totalSolved),
            status: snapshot.hasGoalSettings ? "Goal loaded." : "Suggested a starting goal."
        )
        syncReminderPermissionStatus()
        loadPlannerCompletion()

        if let savedUsername = snapshot.username {
            username = savedUsername
            statusMessage = "Ready to track \(savedUsername)."
        }

        if let cachedStats = snapshot.cachedStats {
            if username.isEmpty {
                username = cachedStats.username
            }

            stats = LeetCodeStats(cachedStats: cachedStats)
            statusMessage = "Loaded \(cachedStats.username). Updated \(formatted(cachedStats.lastUpdated))."
        }
    }

    func saveGoalSettings() {
        let currentTotal = stats?.totalSolved ?? 0
        let target = max(currentTotal + 1, parsePositiveInt(goalTargetText, fallback: savedGoalSettings.targetSolved))
        let weeklyTarget = max(1, parsePositiveInt(weeklyTargetText, fallback: savedGoalSettings.weeklyTarget))
        let difficultyTargets = normalizedDifficultyTargets(fallbackWeeklyTarget: weeklyTarget)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)

        let settings = SharedGoalSettings(
            targetSolved: target,
            weeklyTarget: weeklyTarget,
            weeklyEasyTarget: difficultyTargets.easy,
            weeklyMediumTarget: difficultyTargets.medium,
            weeklyHardTarget: difficultyTargets.hard,
            remindersEnabled: remindersEnabled,
            reminderHour: components.hour ?? savedGoalSettings.reminderHour,
            reminderMinute: components.minute ?? savedGoalSettings.reminderMinute,
            updatedAt: Date()
        )

        sharedStore.saveGoalSettings(settings)
        hasSavedGoalSettings = true
        applyGoalSettings(settings, status: "Saved goal for \(target) solved.")
        updateReminderSchedule(settings, statusPrefix: "Saved goal for \(target) solved.")
        removePlannerCompletionsNotInCurrentPlan()
    }

    func togglePlannerSession(_ id: String) {
        if completedPlannerSessionIDs.contains(id) {
            completedPlannerSessionIDs.remove(id)
        } else {
            completedPlannerSessionIDs.insert(id)
        }

        savePlannerCompletion()
    }

    func resetPlannerWeek() {
        completedPlannerSessionIDs.removeAll()
        savePlannerCompletion()
    }

    func refreshStats() async -> Bool {
        let normalizedUsername = trimmedUsername

        guard !normalizedUsername.isEmpty else {
            statusMessage = LeetCodeProfileError.invalidUsername.localizedDescription
            return false
        }

        isLoading = true
        statusMessage = "Fetching stats for \(normalizedUsername)..."

        defer {
            isLoading = false
        }

        do {
            let freshStats = try await client.fetchStats(for: normalizedUsername)
            username = freshStats.username
            stats = freshStats

            if !hasSavedGoalSettings {
                applyGoalSettings(
                    suggestedGoalSettings(currentTotal: freshStats.totalSolved),
                    status: "Suggested a starting goal."
                )
            }

            sharedStore.saveUsername(freshStats.username)
            sharedStore.saveCachedStats(freshStats.cachedStats)
            statusMessage = "Updated \(freshStats.username). Last checked \(formatted(freshStats.lastUpdated))."
            return true
        } catch let error as LeetCodeProfileError {
            showCachedStatsAfterFailure(error)
            return false
        } catch {
            showCachedStatsAfterFailure(.networkUnavailable)
            return false
        }
    }

    func markWidgetReloadRequested(at date: Date) {
        guard let stats else {
            return
        }

        sharedStore.synchronize()
        statusMessage = "Updated \(stats.username). Widget reload requested at \(formatted(date)). Saved \(stats.totalSolved) solved."
    }

    private func showCachedStatsAfterFailure(_ error: LeetCodeProfileError) {
        if let cachedStats = sharedStore.cachedStats {
            stats = LeetCodeStats(cachedStats: cachedStats)

            if trimmedUsername.isEmpty {
                username = cachedStats.username
            }

            statusMessage = "\(error.localizedDescription) Showing saved stats from \(formatted(cachedStats.lastUpdated))."
        } else {
            statusMessage = "\(error.localizedDescription) No saved stats yet."
        }
    }

    private func statText(_ value: Int?) -> String {
        guard let value else {
            return "--"
        }

        return "\(value)"
    }

    private func nextMilestone(after totalSolved: Int) -> Int {
        ((totalSolved / 10) + 1) * 10
    }

    private func suggestedGoalSettings(currentTotal: Int?) -> SharedGoalSettings {
        let target = currentTotal.map(nextMilestone) ?? SharedGoalSettings.default.targetSolved

        return SharedGoalSettings(
            targetSolved: target,
            weeklyTarget: SharedGoalSettings.default.weeklyTarget,
            weeklyEasyTarget: SharedGoalSettings.default.weeklyEasyTarget,
            weeklyMediumTarget: SharedGoalSettings.default.weeklyMediumTarget,
            weeklyHardTarget: SharedGoalSettings.default.weeklyHardTarget,
            remindersEnabled: SharedGoalSettings.default.remindersEnabled,
            reminderHour: SharedGoalSettings.default.reminderHour,
            reminderMinute: SharedGoalSettings.default.reminderMinute,
            updatedAt: Date()
        )
    }

    private var goalTargetValue: Int {
        max(1, parsePositiveInt(goalTargetText, fallback: savedGoalSettings.targetSolved))
    }

    private var weeklyTargetValue: Int {
        max(1, parsePositiveInt(weeklyTargetText, fallback: savedGoalSettings.weeklyTarget))
    }

    private var weeklyEasyTargetValue: Int {
        max(0, parsePositiveInt(weeklyEasyTargetText, fallback: savedGoalSettings.weeklyEasyTarget ?? suggestedDifficultyTargets(for: weeklyTargetValue).easy))
    }

    private var weeklyMediumTargetValue: Int {
        max(0, parsePositiveInt(weeklyMediumTargetText, fallback: savedGoalSettings.weeklyMediumTarget ?? suggestedDifficultyTargets(for: weeklyTargetValue).medium))
    }

    private var weeklyHardTargetValue: Int {
        max(0, parsePositiveInt(weeklyHardTargetText, fallback: savedGoalSettings.weeklyHardTarget ?? suggestedDifficultyTargets(for: weeklyTargetValue).hard))
    }

    private func applyGoalSettings(_ settings: SharedGoalSettings, status: String) {
        savedGoalSettings = settings
        goalTargetText = "\(settings.targetSolved)"
        weeklyTargetText = "\(settings.weeklyTarget)"
        let difficultyTargets = difficultyTargets(from: settings)
        weeklyEasyTargetText = "\(difficultyTargets.easy)"
        weeklyMediumTargetText = "\(difficultyTargets.medium)"
        weeklyHardTargetText = "\(difficultyTargets.hard)"
        remindersEnabled = settings.remindersEnabled
        reminderTime = reminderDate(hour: settings.reminderHour, minute: settings.reminderMinute)
        goalStatusMessage = status
    }

    private func syncReminderPermissionStatus() {
        Task {
            reminderPermissionText = await reminderScheduler.currentPermissionText()
        }
    }

    private func updateReminderSchedule(_ settings: SharedGoalSettings, statusPrefix: String) {
        Task {
            do {
                let result = try await reminderScheduler.apply(
                    settings: settings,
                    username: displayUsername,
                    weeklyMix: weeklyPracticeMixText
                )
                goalStatusMessage = "\(statusPrefix) \(result.statusText)"
                reminderPermissionText = result.permissionText
            } catch {
                goalStatusMessage = "\(statusPrefix) \(error.localizedDescription)"
                reminderPermissionText = error.localizedDescription
            }
        }
    }

    private func parsePositiveInt(_ text: String, fallback: Int) -> Int {
        let digits = text.filter(\.isNumber)
        return Int(digits) ?? fallback
    }

    private func normalizedDifficultyTargets(fallbackWeeklyTarget: Int) -> (easy: Int, medium: Int, hard: Int) {
        let fallback = suggestedDifficultyTargets(for: fallbackWeeklyTarget)
        let easy = max(0, parsePositiveInt(weeklyEasyTargetText, fallback: savedGoalSettings.weeklyEasyTarget ?? fallback.easy))
        let medium = max(0, parsePositiveInt(weeklyMediumTargetText, fallback: savedGoalSettings.weeklyMediumTarget ?? fallback.medium))
        let hard = max(0, parsePositiveInt(weeklyHardTargetText, fallback: savedGoalSettings.weeklyHardTarget ?? fallback.hard))

        guard easy + medium + hard > 0 else {
            return fallback
        }

        return (easy, medium, hard)
    }

    private func difficultyTargets(from settings: SharedGoalSettings) -> (easy: Int, medium: Int, hard: Int) {
        let fallback = suggestedDifficultyTargets(for: settings.weeklyTarget)
        return (
            max(0, settings.weeklyEasyTarget ?? fallback.easy),
            max(0, settings.weeklyMediumTarget ?? fallback.medium),
            max(0, settings.weeklyHardTarget ?? fallback.hard)
        )
    }

    private func suggestedDifficultyTargets(for weeklyTarget: Int) -> (easy: Int, medium: Int, hard: Int) {
        let easy = max(1, Int((Double(weeklyTarget) * 0.20).rounded(.down)))
        let hard = weeklyTarget >= 5 ? 1 : 0
        let medium = max(0, weeklyTarget - easy - hard)
        return (easy, medium, hard)
    }

    private func difficultyMixText(easy: Int, medium: Int, hard: Int) -> String {
        if hard > 0 {
            return "\(easy) Easy, \(medium) Medium, \(hard) Hard"
        }

        return "\(easy) Easy, \(medium) Medium"
    }

    private func paceText(for weeklyTarget: Int) -> String {
        if weeklyTarget >= 7 {
            let perDay = Double(weeklyTarget) / 7
            return String(format: "%.1f per day", perDay)
        }

        let spacing = Int(ceil(7.0 / Double(max(1, weeklyTarget))))
        return spacing <= 1 ? "1 per day" : "1 every \(spacing) days"
    }

    private func reminderDate(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: min(23, max(0, hour)),
            minute: min(59, max(0, minute)),
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private func formatted(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private var plannerCompletionKey: String {
        "com.hyder.LeetTracker.planner.completed.\(WeeklyPlannerFactory.weekIdentifier())"
    }

    private func loadPlannerCompletion() {
        let savedIDs = plannerDefaults.stringArray(forKey: plannerCompletionKey) ?? []
        completedPlannerSessionIDs = Set(savedIDs)
        removePlannerCompletionsNotInCurrentPlan()
    }

    private func savePlannerCompletion() {
        plannerDefaults.set(Array(completedPlannerSessionIDs).sorted(), forKey: plannerCompletionKey)
    }

    private func removePlannerCompletionsNotInCurrentPlan() {
        let validIDs = Set(plannerSessions.map(\.id))
        let filteredIDs = completedPlannerSessionIDs.intersection(validIDs)

        guard filteredIDs != completedPlannerSessionIDs else {
            return
        }

        completedPlannerSessionIDs = filteredIDs
        savePlannerCompletion()
    }
}
