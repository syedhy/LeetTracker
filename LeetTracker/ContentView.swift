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
                    analyticsSection
                    DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                        .frame(width: 360)
                }

                VStack(spacing: 20) {
                    analyticsSection
                    DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                }
            }

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
                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.milestoneProgress
                    )

                    ReminderPlanPanel(refreshText: viewModel.refreshCadenceText)
                        .frame(width: 340)
                }

                VStack(spacing: 20) {
                    GoalPlanPanel(
                        title: viewModel.goalPlanTitle,
                        subtitle: viewModel.goalPlanSubtitle,
                        progress: viewModel.milestoneProgress
                    )

                    ReminderPlanPanel(refreshText: viewModel.refreshCadenceText)
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
                        tint: AppColor.brand
                    )

                    WidgetIdeaPanel(
                        title: "Goal Pace",
                        detail: "Milestone progress, remaining problems, and whether you are on track.",
                        systemImage: "speedometer",
                        tint: AppColor.medium
                    )

                    WidgetIdeaPanel(
                        title: "Daily Focus",
                        detail: "One small practice target with reminder timing.",
                        systemImage: "calendar.badge.clock",
                        tint: AppColor.easy
                    )
                }

                VStack(spacing: 20) {
                    WidgetIdeaPanel(title: "Progress", detail: "Current solved count, difficulty mix, and last updated time.", systemImage: "checkmark.seal.fill", tint: AppColor.brand)
                    WidgetIdeaPanel(title: "Goal Pace", detail: "Milestone progress, remaining problems, and whether you are on track.", systemImage: "speedometer", tint: AppColor.medium)
                    WidgetIdeaPanel(title: "Daily Focus", detail: "One small practice target with reminder timing.", systemImage: "calendar.badge.clock", tint: AppColor.easy)
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
                tint: viewModel.isLoading ? .orange : .green
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
                        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.quaternary, lineWidth: 1)
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
                    InsightCard(title: "Next Milestone", value: viewModel.nextMilestoneText, tint: AppColor.medium)
                    InsightCard(title: "Remaining", value: viewModel.milestoneRemainingText, tint: AppColor.hard)
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    DetailRow(title: "History", value: "Local snapshots")
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
                ReminderPlanPanel(refreshText: viewModel.refreshCadenceText)
            }

            VStack(spacing: 20) {
                DifficultyBreakdownPanel(stats: viewModel.statsSnapshot)
                ReminderPlanPanel(refreshText: viewModel.refreshCadenceText)
            }
        }
    }

    private func pageHeader(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.brand)
                .frame(width: 44, height: 44)
                .background(AppColor.brand.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

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
                    Text(viewModel.nextMilestoneText)
                        .font(.title.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("\(viewModel.milestoneRemainingText) remaining")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: viewModel.milestoneProgress)
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
    static let brand = Color(red: 0.22, green: 0.58, blue: 0.98)
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
                        .fill(AppColor.easy)
                        .frame(width: 8, height: 8)

                    Text("Every 2 min")
                        .font(.callout.weight(.medium))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .frame(width: 214)
        .background(.ultraThinMaterial)
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
                isSelected ? AppColor.brand.opacity(configuration.isPressed ? 0.18 : 0.14) : .clear,
                in: RoundedRectangle(cornerRadius: 10)
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColor.brand)
                        .frame(width: 3, height: 18)
                }
            }
    }
}

private struct AppSurfaceBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .controlBackgroundColor).opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct AppIconMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.brand.gradient)

            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 48, height: 48)
        .shadow(color: AppColor.brand.opacity(0.28), radius: 16, y: 8)
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
            .background(tint.opacity(0.12), in: Capsule())
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
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.quaternary, lineWidth: 1)
            }
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
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(1)

                    Text(lastUpdated)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.brand)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(total)
                    .font(.system(size: 58, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("solved")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.13),
                    Color(red: 0.04, green: 0.06, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
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
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.22), lineWidth: 1)
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
                    .foregroundStyle(AppColor.brand)
                    .padding(.top, 2)
            }

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
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
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.18), lineWidth: 1)
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

private struct GoalPlanPanel: View {
    let title: String
    let subtitle: String
    let progress: Double

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

                HStack(spacing: 10) {
                    Label("Weekly target", systemImage: "calendar")
                    Spacer()
                    Text("Plan next")
                        .fontWeight(.semibold)
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ReminderPlanPanel: View {
    let refreshText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Reminders", systemImage: "bell.badge")

                ReminderRow(title: "Daily practice", detail: "Pick a gentle time window", tint: AppColor.easy)
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
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

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
            .background(AppColor.brand.opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 0.42), in: RoundedRectangle(cornerRadius: 10))
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
            .background(.quaternary.opacity(configuration.isPressed ? 0.9 : 0.62), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ContentView()
}

@MainActor
private final class LeetTrackerViewModel: ObservableObject {
    @Published var username = ""
    @Published private(set) var stats: LeetCodeStats?
    @Published private(set) var statusMessage = "Enter a LeetCode username to prepare tracking."
    @Published private(set) var isLoading = false

    private let client: LeetCodeClient
    private let sharedStore: SharedLeetTrackerStore

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

    var milestoneRemainingText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        return "\(nextMilestone(after: totalSolved) - totalSolved)"
    }

    var milestoneProgress: Double {
        guard let totalSolved = stats?.totalSolved else {
            return 0
        }

        let previousMilestone = max(0, (totalSolved / 10) * 10)
        let nextMilestone = nextMilestone(after: totalSolved)
        let span = max(1, nextMilestone - previousMilestone)

        return Double(totalSolved - previousMilestone) / Double(span)
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

    var analyticsSummary: String {
        guard let stats, stats.totalSolved > 0 else {
            return "No profile data is loaded yet. Save your LeetCode username and refresh once so LeetTracker can turn your public solved counts into readable progress signals."
        }

        let mediumHard = stats.mediumSolved + stats.hardSolved
        let mediumHardPercentage = Int((Double(mediumHard) / Double(stats.totalSolved) * 100).rounded())
        let next = nextMilestone(after: stats.totalSolved)
        let remaining = next - stats.totalSolved

        return "You have solved \(stats.totalSolved) problems. \(mediumHardPercentage)% are Medium or Hard, which is the most useful signal for interview readiness. Your next clean milestone is \(next) solved, so \(remaining) more problem\(remaining == 1 ? "" : "s") gets you there."
    }

    var goalPlanTitle: String {
        guard let totalSolved = stats?.totalSolved else {
            return "Set your first goal"
        }

        return "Reach \(nextMilestone(after: totalSolved)) solved"
    }

    var goalPlanSubtitle: String {
        guard let totalSolved = stats?.totalSolved else {
            return "After a profile refresh, LeetTracker will suggest a simple milestone goal from your current solved count."
        }

        let remaining = nextMilestone(after: totalSolved) - totalSolved
        return "\(remaining) problem\(remaining == 1 ? "" : "s") left. Keep this goal small, measurable, and visible on the widget."
    }

    func loadSavedState() {
        let snapshot = sharedStore.snapshot

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

    private func formatted(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
}
