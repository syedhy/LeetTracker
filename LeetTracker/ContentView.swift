import Foundation
import SwiftUI
import WidgetKit

private enum AppSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case analytics = "Analytics"
    case goals = "Goals"
    case widgets = "Widgets"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            return "rectangle.3.group"
        case .analytics:
            return "chart.xyaxis.line"
        case .goals:
            return "target"
        case .widgets:
            return "square.grid.2x2"
        case .settings:
            return "gearshape"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = LeetTrackerViewModel()
    @State private var selectedSection = AppSection.dashboard

    var body: some View {
        ZStack {
            AppSurfaceBackground()

            HStack(spacing: 0) {
                AppSidebar(selectedSection: $selectedSection)

                Divider()

                ScrollView {
                    selectedContent
                        .padding(28)
                }
            }
        }
        .frame(minWidth: 780, idealWidth: 1120, minHeight: 620)
        .onAppear {
            viewModel.loadSavedState()
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .dashboard:
            dashboard
        case .analytics:
            analyticsPage
        case .goals:
            goalsPage
        case .widgets:
            widgetsPage
        case .settings:
            settingsPage
        }
    }

    private var dashboard: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    statsSection
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 20) {
                        goalSection
                        dataHealthSection
                    }
                    .frame(width: 300)
                }

                VStack(spacing: 20) {
                    statsSection
                    goalSection
                    dataHealthSection
                }
            }

            planningSnapshot
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var analyticsPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            pageHeader(
                title: "Analytics",
                subtitle: "Readable signals from your public LeetCode progress.",
                systemImage: "chart.line.uptrend.xyaxis"
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    AnalyticsScorePanel(
                        score: viewModel.readinessScore,
                        title: viewModel.readinessTitle,
                        detail: viewModel.readinessDetail
                    )
                    .frame(width: 300)

                    FocusRecommendationPanel(
                        title: viewModel.focusRecommendationTitle,
                        detail: viewModel.focusRecommendationDetail,
                        tint: viewModel.focusRecommendationTint
                    )

                    DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                        .frame(width: 360)
                }

                VStack(spacing: 20) {
                    AnalyticsScorePanel(
                        score: viewModel.readinessScore,
                        title: viewModel.readinessTitle,
                        detail: viewModel.readinessDetail
                    )

                    FocusRecommendationPanel(
                        title: viewModel.focusRecommendationTitle,
                        detail: viewModel.focusRecommendationDetail,
                        tint: viewModel.focusRecommendationTint
                    )

                    analyticsSection
                    DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                }
            }

            analyticsSection
            AnalyticsNarrativePanel(summary: viewModel.analyticsSummary)
        }
    }

    private var goalsPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            pageHeader(
                title: "Goals",
                subtitle: "Plan the next step without making the app noisy.",
                systemImage: "target"
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    GoalEditorPanel(
                        targetText: $viewModel.goalTargetText,
                        weeklyTargetText: $viewModel.weeklyTargetText,
                        remindersEnabled: $viewModel.remindersEnabled,
                        reminderTime: $viewModel.reminderTime,
                        statusText: viewModel.goalStatusMessage,
                        saveAction: viewModel.saveGoalSettings
                    )
                    .frame(width: 360)

                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.goalProgress,
                        detailRows: viewModel.goalDetailRows
                    )

                    ReminderPlanPanel(
                        refreshText: viewModel.refreshCadenceText,
                        remindersEnabled: viewModel.remindersEnabled,
                        reminderTimeText: viewModel.reminderTimeText
                    )
                        .frame(width: 340)
                }

                VStack(spacing: 20) {
                    GoalEditorPanel(
                        targetText: $viewModel.goalTargetText,
                        weeklyTargetText: $viewModel.weeklyTargetText,
                        remindersEnabled: $viewModel.remindersEnabled,
                        reminderTime: $viewModel.reminderTime,
                        statusText: viewModel.goalStatusMessage,
                        saveAction: viewModel.saveGoalSettings
                    )

                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.goalProgress,
                        detailRows: viewModel.goalDetailRows
                    )

                    ReminderPlanPanel(
                        refreshText: viewModel.refreshCadenceText,
                        remindersEnabled: viewModel.remindersEnabled,
                        reminderTimeText: viewModel.reminderTimeText
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
                    WidgetIdeaPanel(
                        title: "Progress",
                        detail: "Current solved count, difficulty mix, and last updated time.",
                        systemImage: "checkmark.seal.fill",
                        tint: AppColor.ink
                    )

                    WidgetIdeaPanel(
                        title: "Goal Pace",
                        detail: "Milestone progress, remaining problems, and whether you are on track.",
                        systemImage: "speedometer",
                        tint: AppColor.ink
                    )

                    WidgetIdeaPanel(
                        title: "Daily Focus",
                        detail: "One small practice target with reminder timing.",
                        systemImage: "calendar.badge.clock",
                        tint: AppColor.ink
                    )
                }

                VStack(spacing: 20) {
                    WidgetIdeaPanel(title: "Progress", detail: "Current solved count, difficulty mix, and last updated time.", systemImage: "checkmark.seal.fill", tint: AppColor.ink)
                    WidgetIdeaPanel(title: "Goal Pace", detail: "Milestone progress, remaining problems, and whether you are on track.", systemImage: "speedometer", tint: AppColor.ink)
                    WidgetIdeaPanel(title: "Daily Focus", detail: "One small practice target with reminder timing.", systemImage: "calendar.badge.clock", tint: AppColor.ink)
                }
            }
        }
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
            SectionHeader(title: "Dashboard", systemImage: "chart.bar.xaxis")

            TotalSolvedCard(
                total: viewModel.totalSolvedText,
                username: viewModel.displayUsername,
                lastUpdated: viewModel.lastUpdatedText
            )

            HStack(spacing: 12) {
                DifficultyCard(title: "Easy", value: viewModel.easySolvedText, tint: AppColor.easy)
                DifficultyCard(title: "Medium", value: viewModel.mediumSolvedText, tint: AppColor.medium)
                DifficultyCard(title: "Hard", value: viewModel.hardSolvedText, tint: AppColor.hard)
            }
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
                GoalPlanPanel(
                    title: viewModel.goalPlanTitle,
                    subtitle: viewModel.goalPlanSubtitle,
                    progress: viewModel.goalProgress,
                    detailRows: viewModel.goalDetailRows
                )
            }

            VStack(spacing: 20) {
                DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                GoalPlanPanel(
                    title: viewModel.goalPlanTitle,
                    subtitle: viewModel.goalPlanSubtitle,
                    progress: viewModel.goalProgress,
                    detailRows: viewModel.goalDetailRows
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
                    Text(viewModel.goalTargetDisplayText)
                        .font(.title.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("\(viewModel.goalRemainingText) remaining")
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

private enum AppColor {
    static let ink = Color(red: 0.08, green: 0.08, blue: 0.075)
    static let paper = Color(red: 0.98, green: 0.975, blue: 0.94)
    static let paperWarm = Color(red: 0.94, green: 0.93, blue: 0.88)
    static let graphite = Color(red: 0.42, green: 0.42, blue: 0.39)
    static let line = Color(red: 0.12, green: 0.12, blue: 0.11)
    static let brand = ink
    static let easy = Color(red: 0.18, green: 0.73, blue: 0.38)
    static let medium = Color(red: 0.95, green: 0.58, blue: 0.08)
    static let hard = Color(red: 0.92, green: 0.25, blue: 0.42)
}

private struct AppSidebar: View {
    @Binding var selectedSection: AppSection

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                AppIconMark()
                    .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetTracker")
                        .font(.headline.weight(.semibold))

                    Text("Practice OS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 8)

            VStack(spacing: 6) {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: section.systemImage)
                                .frame(width: 18)

                            Text(section.rawValue)
                                .lineLimit(1)

                            Spacer()
                        }
                    }
                    .buttonStyle(SidebarButtonStyle(isSelected: selectedSection == section))
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Text("Auto Refresh")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColor.ink)
                        .frame(width: 8, height: 8)

                    Text("Every 2 min")
                        .font(.callout.weight(.medium))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.line.opacity(0.45), lineWidth: 1)
            }
        }
        .padding(20)
        .frame(width: 214)
        .background(AppColor.paperWarm.opacity(0.82))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColor.line.opacity(0.2))
                .frame(width: 1)
        }
    }
}

private struct SidebarButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(
                isSelected ? AppColor.ink.opacity(configuration.isPressed ? 0.12 : 0.08) : .clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    Rectangle()
                        .fill(AppColor.ink)
                        .frame(width: 3, height: 18)
                }
            }
    }
}

private struct AppSurfaceBackground: View {
    var body: some View {
        ZStack {
            AppColor.paper

            DoodleBackdrop()
                .stroke(AppColor.line.opacity(0.07), lineWidth: 1.2)
                .padding(18)
        }
        .ignoresSafeArea()
    }
}

private struct DoodleBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 72
        var x = rect.minX - step

        while x < rect.maxX + step {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addCurve(
                to: CGPoint(x: x + 26, y: rect.maxY),
                control1: CGPoint(x: x + 18, y: rect.minY + rect.height * 0.28),
                control2: CGPoint(x: x - 16, y: rect.minY + rect.height * 0.72)
            )
            x += step
        }

        var y = rect.minY + 40
        while y < rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: y + 18),
                control1: CGPoint(x: rect.minX + rect.width * 0.32, y: y - 12),
                control2: CGPoint(x: rect.minX + rect.width * 0.68, y: y + 28)
            )
            y += step * 1.25
        }

        return path
    }
}

private struct AppIconMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.ink)

            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColor.paper)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 48, height: 48)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColor.paper.opacity(0.24), lineWidth: 1)
        }
        .shadow(color: AppColor.ink.opacity(0.18), radius: 12, y: 7)
    }
}

private struct StatusPill: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColor.paperWarm, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppColor.line.opacity(0.4), lineWidth: 1)
            }
    }
}

private struct Panel<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(AppColor.paper.opacity(0.94), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.line.opacity(0.42), lineWidth: 1.2)
            }
            .shadow(color: AppColor.ink.opacity(0.05), radius: 10, y: 6)
    }
}

private struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

private struct TotalSolvedCard: View {
    let total: String
    let username: String
    let lastUpdated: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.headline)
                        .foregroundStyle(AppColor.paper.opacity(0.76))
                        .lineLimit(1)

                    Text(lastUpdated)
                        .font(.caption)
                        .foregroundStyle(AppColor.paper.opacity(0.52))
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.paper)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(total)
                    .font(.system(size: 58, weight: .semibold, design: .rounded))
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
            in: RoundedRectangle(cornerRadius: 8)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.line, lineWidth: 1.2)
        }
    }
}

private struct DifficultyCard: View {
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
        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.72), lineWidth: 1.4)
        }
    }
}

private struct StatusPanel: View {
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
        .background(AppColor.paperWarm.opacity(0.75), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.line.opacity(0.3), lineWidth: 1)
        }
    }
}

private struct InsightCard: View {
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
                .stroke(tint.opacity(0.54), lineWidth: 1.1)
        }
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

private struct DifficultyBreakdownPanel: View {
    let stats: LeetCodeStats?

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Difficulty Breakdown", systemImage: "chart.bar.fill")

                if let stats, stats.totalSolved > 0 {
                    VStack(spacing: 12) {
                        DifficultyBarRow(title: "Easy", value: stats.easySolved, total: stats.totalSolved, tint: AppColor.easy)
                        DifficultyBarRow(title: "Medium", value: stats.mediumSolved, total: stats.totalSolved, tint: AppColor.medium)
                        DifficultyBarRow(title: "Hard", value: stats.hardSolved, total: stats.totalSolved, tint: AppColor.hard)
                    }

                    Text("This shows where your solved count is concentrated. A healthier interview mix usually grows medium problems steadily while keeping easy warmups active.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    EmptyPanelMessage(
                        title: "No analytics yet",
                        message: "Save a LeetCode username and refresh once to generate readable charts."
                    )
                }
            }
        }
    }
}

private struct DifficultyBarRow: View {
    let title: String
    let value: Int
    let total: Int
    let tint: Color

    private var percentage: Int {
        guard total > 0 else {
            return 0
        }

        return Int((Double(value) / Double(total) * 100).rounded())
    }

    private var progress: Double {
        guard total > 0 else {
            return 0
        }

        return Double(value) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(tint)
                        .frame(width: 9, height: 9)

                    Text(title)
                        .font(.callout.weight(.semibold))
                }

                Spacer()

                Text("\(value) · \(percentage)%")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary.opacity(0.58))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(tint.gradient)
                        .frame(width: max(8, proxy.size.width * progress))
                }
            }
            .frame(height: 8)
        }
    }
}

private struct AnalyticsNarrativePanel: View {
    let summary: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "What This Means", systemImage: "text.bubble")

                Text(summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct AnalyticsScorePanel: View {
    let score: Int
    let title: String
    let detail: String

    private var progress: Double {
        min(1, max(0, Double(score) / 100))
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Readiness", systemImage: "gauge.with.dots.needle.67percent")

                HStack(alignment: .center, spacing: 18) {
                    ZStack {
                        Circle()
                            .stroke(.quaternary.opacity(0.7), lineWidth: 12)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AppColor.ink.gradient,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        Text("\(score)")
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                    }
                    .frame(width: 104, height: 104)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(detail)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

private struct FocusRecommendationPanel: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Next Best Move", systemImage: "sparkles")

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(tint)
                        .frame(width: 42, height: 42)
                        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tint.opacity(0.58), lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.title3.weight(.semibold))

                        Text(detail)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

private struct GoalEditorPanel: View {
    @Binding var targetText: String
    @Binding var weeklyTargetText: String
    @Binding var remindersEnabled: Bool
    @Binding var reminderTime: Date

    let statusText: String
    let saveAction: () -> Void

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Set Goal", systemImage: "slider.horizontal.3")

                VStack(alignment: .leading, spacing: 12) {
                    GoalField(title: "Target solved", text: $targetText, systemImage: "target")
                    GoalField(title: "Weekly target", text: $weeklyTargetText, systemImage: "calendar")

                    Toggle(isOn: $remindersEnabled) {
                        Label("Practice reminder", systemImage: "bell.badge")
                    }
                    .toggleStyle(.switch)

                    DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .disabled(!remindersEnabled)
                }

                HStack(spacing: 10) {
                    Button(action: saveAction) {
                        Label("Save Goal", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
        }
    }
}

private struct GoalField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(AppColor.paperWarm.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.line.opacity(0.5), lineWidth: 1)
                }
        }
    }
}

private struct GoalPlanPanel: View {
    let title: String
    let subtitle: String
    let progress: Double
    let detailRows: [(String, String)]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Active Goal", systemImage: "target")

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ProgressView(value: progress)
                    .tint(AppColor.brand)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(detailRows, id: \.0) { row in
                        DetailRow(title: row.0, value: row.1)
                    }
                }
            }
        }
    }
}

private struct ReminderPlanPanel: View {
    let refreshText: String
    let remindersEnabled: Bool
    let reminderTimeText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Reminders", systemImage: "bell.badge")

                ReminderRow(
                    title: "Daily practice",
                    detail: remindersEnabled ? reminderTimeText : "Off",
                    tint: remindersEnabled ? AppColor.easy : .secondary
                )
                ReminderRow(title: "Weekly review", detail: "Summarize progress and reset plan", tint: AppColor.brand)
                ReminderRow(title: "Widget refresh", detail: refreshText, tint: AppColor.medium)

                Divider()

                DetailRow(title: "Quiet hours", value: "Not set")
                DetailRow(title: "Notification style", value: "Gentle")
            }
        }
    }
}

private struct ReminderRow: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.callout.weight(.semibold))

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

private struct WidgetIdeaPanel: View {
    let title: String
    let detail: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(AppColor.paperWarm.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(tint.opacity(0.6), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3.weight(.semibold))

                    Text(detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct EmptyPanelMessage: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(AppColor.ink.opacity(isEnabled ? (configuration.isPressed ? 0.74 : 1) : 0.42), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(AppColor.paperWarm.opacity(configuration.isPressed ? 0.95 : 0.72), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.line.opacity(0.42), lineWidth: 1)
            }
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
    @Published var remindersEnabled = false
    @Published var reminderTime = Date()
    @Published private(set) var stats: LeetCodeStats?
    @Published private(set) var statusMessage = "Enter a LeetCode username to prepare tracking."
    @Published private(set) var goalStatusMessage = "Goal settings are ready."
    @Published private(set) var isLoading = false

    private let client: LeetCodeClient
    private let sharedStore: SharedLeetTrackerStore
    private var savedGoalSettings = SharedGoalSettings.default
    private var hasSavedGoalSettings = false

    init(
        client: LeetCodeClient = LeetCodeClient(),
        sharedStore: SharedLeetTrackerStore = SharedLeetTrackerStore()
    ) {
        self.client = client
        self.sharedStore = sharedStore
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

    var goalDetailRows: [(String, String)] {
        [
            ("Target", goalTargetDisplayText),
            ("Remaining", goalRemainingText),
            ("Weekly pace", "\(weeklyTargetValue) problems"),
            ("ETA", estimatedWeeksText)
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
            return "Refresh a profile once to calculate a score from solved count, goal progress, and difficulty balance."
        }

        return "\(difficultyMixText) are Medium or Hard, with \(goalRemainingText) left for your current goal."
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

        return "You have solved \(stats.totalSolved) problems. \(mediumHardPercentage)% are Medium or Hard, which is the most useful signal for interview readiness. Your current goal is \(goalTargetValue) solved, so \(remaining) more problem\(remaining == 1 ? "" : "s") gets you there at about \(estimatedWeeksText)."
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
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: reminderTime)
    }

    func loadSavedState() {
        let snapshot = sharedStore.snapshot
        hasSavedGoalSettings = snapshot.hasGoalSettings
        applyGoalSettings(
            snapshot.hasGoalSettings ? snapshot.goalSettings : suggestedGoalSettings(currentTotal: snapshot.cachedStats?.totalSolved),
            status: snapshot.hasGoalSettings ? "Goal loaded." : "Suggested a starting goal."
        )

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
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)

        let settings = SharedGoalSettings(
            targetSolved: target,
            weeklyTarget: weeklyTarget,
            remindersEnabled: remindersEnabled,
            reminderHour: components.hour ?? savedGoalSettings.reminderHour,
            reminderMinute: components.minute ?? savedGoalSettings.reminderMinute,
            updatedAt: Date()
        )

        sharedStore.saveGoalSettings(settings)
        hasSavedGoalSettings = true
        applyGoalSettings(settings, status: "Saved goal for \(target) solved.")
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

    private func applyGoalSettings(_ settings: SharedGoalSettings, status: String) {
        savedGoalSettings = settings
        goalTargetText = "\(settings.targetSolved)"
        weeklyTargetText = "\(settings.weeklyTarget)"
        remindersEnabled = settings.remindersEnabled
        reminderTime = reminderDate(hour: settings.reminderHour, minute: settings.reminderMinute)
        goalStatusMessage = status
    }

    private func parsePositiveInt(_ text: String, fallback: Int) -> Int {
        let digits = text.filter(\.isNumber)
        return Int(digits) ?? fallback
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
}
