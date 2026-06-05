import SwiftUI
import WidgetKit

struct LeetTrackerEntry: TimelineEntry {
    let date: Date
    let username: String?
    let stats: WidgetStatsSnapshot
    let goalSettings: SharedGoalSettings
    let hasGoalSettings: Bool
    let state: LeetTrackerWidgetState
}

enum LeetTrackerWidgetState {
    case loading
    case empty
    case success
    case offline(message: String)
    case error(title: String, message: String)
}

enum LeetTrackerWidgetVariant {
    case progress
    case motivation
    case goalPace
}

struct LeetTrackerTimelineProvider: TimelineProvider {
    private let client = LeetCodeClient()
    private let sharedStore = SharedLeetTrackerStore()

    func placeholder(in context: Context) -> LeetTrackerEntry {
        LeetTrackerEntry(
            date: Date(),
            username: "leetcode-user",
            stats: .placeholder,
            goalSettings: .default,
            hasGoalSettings: false,
            state: .loading
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LeetTrackerEntry) -> Void) {
        completion(cachedEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeetTrackerEntry>) -> Void) {
        Task {
            let entry = await refreshedEntry()
            let nextRefresh = Date().addingTimeInterval(LeetTrackerWidgetConfiguration.refreshInterval)
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private var cachedEntry: LeetTrackerEntry {
        let snapshot = sharedStore.snapshot

        guard let username = snapshot.username else {
            return LeetTrackerEntry(
                date: Date(),
                username: nil,
                stats: .placeholder,
                goalSettings: snapshot.goalSettings,
                hasGoalSettings: snapshot.hasGoalSettings,
                state: .empty
            )
        }

        guard let cachedStats = snapshot.cachedStats else {
            return LeetTrackerEntry(
                date: Date(),
                username: username,
                stats: .placeholder,
                goalSettings: snapshot.goalSettings,
                hasGoalSettings: snapshot.hasGoalSettings,
                state: .loading
            )
        }

        return LeetTrackerEntry(
            date: Date(),
            username: cachedStats.username,
            stats: WidgetStatsSnapshot(cachedStats: cachedStats),
            goalSettings: snapshot.goalSettings,
            hasGoalSettings: snapshot.hasGoalSettings,
            state: .success
        )
    }

    private func refreshedEntry() async -> LeetTrackerEntry {
        let snapshot = sharedStore.snapshot

        guard let username = snapshot.username else {
            return LeetTrackerEntry(
                date: Date(),
                username: nil,
                stats: .placeholder,
                goalSettings: snapshot.goalSettings,
                hasGoalSettings: snapshot.hasGoalSettings,
                state: .empty
            )
        }

        do {
            let stats = try await client.fetchStats(for: username)
            let cachedStats = stats.cachedStats
            sharedStore.saveCachedStats(cachedStats)
            let refreshedSnapshot = sharedStore.snapshot

            return LeetTrackerEntry(
                date: Date(),
                username: stats.username,
                stats: WidgetStatsSnapshot(cachedStats: cachedStats),
                goalSettings: refreshedSnapshot.goalSettings,
                hasGoalSettings: refreshedSnapshot.hasGoalSettings,
                state: .success
            )
        } catch {
            if let cachedStats = snapshot.cachedStats {
                return LeetTrackerEntry(
                    date: Date(),
                    username: cachedStats.username,
                    stats: WidgetStatsSnapshot(cachedStats: cachedStats),
                    goalSettings: snapshot.goalSettings,
                    hasGoalSettings: snapshot.hasGoalSettings,
                    state: .offline(message: "Showing saved data")
                )
            }

            return LeetTrackerEntry(
                date: Date(),
                username: username,
                stats: .placeholder,
                goalSettings: snapshot.goalSettings,
                hasGoalSettings: snapshot.hasGoalSettings,
                state: .error(title: "Could not update", message: widgetMessage(for: error))
            )
        }
    }

    private func widgetMessage(for error: Error) -> String {
        if let profileError = error as? LeetCodeProfileError {
            switch profileError {
            case .invalidUsername:
                return "Open LeetTracker and enter a valid username."
            case .profileNotFound:
                return "This LeetCode username was not found."
            case .timeout:
                return "LeetCode took too long to respond."
            case .networkUnavailable:
                return "Check your connection and try again later."
            case .malformedResponse, .endpointChanged:
                return "LeetCode returned an unexpected response."
            }
        }

        return "Open LeetTracker and refresh when ready."
    }
}

struct LeetTrackerWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: LeetTrackerEntry
    let variant: LeetTrackerWidgetVariant

    var body: some View {
        WidgetContainer {
            switch entry.state {
            case .loading:
                WidgetLoadingStateView()
            case .empty:
                WidgetEmptyStateView(
                    title: "Add a username",
                    message: "Open LeetTracker to start tracking your public LeetCode progress."
                )
            case .error(let title, let message):
                WidgetErrorStateView(title: title, message: message)
            case .success:
                if let username = entry.username {
                    widgetView(username: username, status: nil)
                } else {
                    emptyView
                }
            case .offline(let message):
                if let username = entry.username {
                    widgetView(
                        username: username,
                        status: WidgetStatusPill(text: message, tint: LTWidgetColor.warning)
                    )
                } else {
                    emptyView
                }
            }
        }
    }

    private var emptyView: some View {
        WidgetEmptyStateView(
            title: "Add a username",
            message: "Open LeetTracker to start tracking your public LeetCode progress."
        )
    }

    @ViewBuilder
    private func widgetView(username: String, status: WidgetStatusPill?) -> some View {
        switch variant {
        case .progress:
            progressView(username: username, status: status)
        case .motivation:
            motivationView(username: username)
        case .goalPace:
            goalPaceView(username: username)
        }
    }

    @ViewBuilder
    private func progressView(username: String, status: WidgetStatusPill?) -> some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(username: username, stats: entry.stats, goalSettings: entry.goalSettings, status: status)
        default:
            SmallWidgetView(username: username, stats: entry.stats, goalSettings: entry.goalSettings, status: status)
        }
    }

    @ViewBuilder
    private func motivationView(username: String) -> some View {
        switch family {
        case .systemMedium:
            MotivationMediumWidgetView(username: username, stats: entry.stats, goalSettings: entry.goalSettings)
        default:
            MotivationSmallWidgetView(username: username, stats: entry.stats, goalSettings: entry.goalSettings)
        }
    }

    @ViewBuilder
    private func goalPaceView(username: String) -> some View {
        switch family {
        case .systemMedium:
            GoalPaceMediumWidgetView(username: username, stats: entry.stats, goalSettings: entry.goalSettings)
        default:
            GoalPaceSmallWidgetView(stats: entry.stats, goalSettings: entry.goalSettings)
        }
    }
}

struct LeetTrackerWidget: Widget {
    let kind = LeetTrackerWidgetConfiguration.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeetTrackerTimelineProvider()) { entry in
            LeetTrackerWidgetEntryView(entry: entry, variant: .progress)
        }
        .configurationDisplayName("LeetTracker Progress")
        .description("Track solved count, difficulty mix, and target progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LeetTrackerMotivationWidget: Widget {
    let kind = LeetTrackerWidgetConfiguration.motivationKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeetTrackerTimelineProvider()) { entry in
            LeetTrackerWidgetEntryView(entry: entry, variant: .motivation)
        }
        .configurationDisplayName("LeetTracker Motivation")
        .description("A small desktop nudge for the next useful practice block.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LeetTrackerGoalPaceWidget: Widget {
    let kind = LeetTrackerWidgetConfiguration.goalPaceKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeetTrackerTimelineProvider()) { entry in
            LeetTrackerWidgetEntryView(entry: entry, variant: .goalPace)
        }
        .configurationDisplayName("LeetTracker Goal Pace")
        .description("See remaining problems, weekly pace, and target progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    LeetTrackerWidget()
} timeline: {
    LeetTrackerEntry(
        date: Date(),
        username: "Syed__hy",
        stats: .placeholder,
        goalSettings: .default,
        hasGoalSettings: true,
        state: .success
    )
}
