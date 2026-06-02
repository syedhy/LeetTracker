import SwiftUI
import WidgetKit

struct LeetTrackerEntry: TimelineEntry {
    let date: Date
    let username: String?
    let stats: WidgetStatsSnapshot
    let state: LeetTrackerWidgetState
}

enum LeetTrackerWidgetState {
    case loading
    case empty
    case success
    case offline(message: String)
    case error(title: String, message: String)
}

struct LeetTrackerTimelineProvider: TimelineProvider {
    private let client = LeetCodeClient()
    private let sharedStore = SharedLeetTrackerStore()

    func placeholder(in context: Context) -> LeetTrackerEntry {
        LeetTrackerEntry(
            date: Date(),
            username: "leetcode-user",
            stats: .placeholder,
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
        guard let username = sharedStore.username else {
            return LeetTrackerEntry(date: Date(), username: nil, stats: .placeholder, state: .empty)
        }

        guard let cachedStats = sharedStore.cachedStats else {
            return LeetTrackerEntry(date: Date(), username: username, stats: .placeholder, state: .loading)
        }

        return LeetTrackerEntry(
            date: Date(),
            username: cachedStats.username,
            stats: WidgetStatsSnapshot(cachedStats: cachedStats),
            state: .success
        )
    }

    private func refreshedEntry() async -> LeetTrackerEntry {
        guard let username = sharedStore.username else {
            return LeetTrackerEntry(date: Date(), username: nil, stats: .placeholder, state: .empty)
        }

        do {
            let stats = try await client.fetchStats(for: username)
            let cachedStats = stats.cachedStats
            sharedStore.saveCachedStats(cachedStats)
            return LeetTrackerEntry(
                date: Date(),
                username: stats.username,
                stats: WidgetStatsSnapshot(cachedStats: cachedStats),
                state: .success
            )
        } catch {
            if let cachedStats = sharedStore.cachedStats {
                return LeetTrackerEntry(
                    date: Date(),
                    username: cachedStats.username,
                    stats: WidgetStatsSnapshot(cachedStats: cachedStats),
                    state: .offline(message: "Showing saved data")
                )
            }

            return LeetTrackerEntry(
                date: Date(),
                username: username,
                stats: .placeholder,
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
                    statsView(username: username, stats: entry.stats)
                } else {
                    WidgetEmptyStateView(
                        title: "Add a username",
                        message: "Open LeetTracker to start tracking your public LeetCode progress."
                    )
                }
            case .offline(let message):
                if let username = entry.username {
                    statsView(
                        username: username,
                        stats: entry.stats,
                        status: WidgetStatusPill(text: message, tint: LTWidgetColor.warning)
                    )
                } else {
                    WidgetEmptyStateView(
                        title: "Add a username",
                        message: "Open LeetTracker to start tracking your public LeetCode progress."
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func statsView(
        username: String,
        stats: WidgetStatsSnapshot,
        status: WidgetStatusPill? = nil
    ) -> some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(username: username, stats: stats, status: status)
        default:
            SmallWidgetView(username: username, stats: stats, status: status)
        }
    }
}

struct LeetTrackerWidget: Widget {
    let kind = LeetTrackerWidgetConfiguration.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeetTrackerTimelineProvider()) { entry in
            LeetTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LeetTracker")
        .description("Track your public LeetCode progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    LeetTrackerWidget()
} timeline: {
    LeetTrackerEntry(date: Date(), username: "leetcode-user", stats: .placeholder, state: .success)
    LeetTrackerEntry(date: Date(), username: "leetcode-user", stats: .placeholder, state: .offline(message: "Showing saved data"))
    LeetTrackerEntry(date: Date(), username: nil, stats: .placeholder, state: .empty)
}
