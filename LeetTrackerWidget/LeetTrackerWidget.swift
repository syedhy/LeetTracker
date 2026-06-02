import SwiftUI
import WidgetKit

struct LeetTrackerEntry: TimelineEntry {
    let date: Date
    let username: String?
    let stats: CachedLeetCodeStats
}

struct LeetTrackerTimelineProvider: TimelineProvider {
    private let client = LeetCodeClient()
    private let sharedStore = SharedLeetTrackerStore()
    private let refreshInterval: TimeInterval = 30 * 60

    func placeholder(in context: Context) -> LeetTrackerEntry {
        LeetTrackerEntry(date: Date(), username: "leetcode-user", stats: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LeetTrackerEntry) -> Void) {
        completion(cachedEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeetTrackerEntry>) -> Void) {
        Task {
            let entry = await refreshedEntry()
            let nextRefresh = Date().addingTimeInterval(refreshInterval)
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private var cachedEntry: LeetTrackerEntry {
        LeetTrackerEntry(
            date: Date(),
            username: sharedStore.username,
            stats: sharedStore.cachedStats ?? .placeholder
        )
    }

    private func refreshedEntry() async -> LeetTrackerEntry {
        guard let username = sharedStore.username else {
            return LeetTrackerEntry(date: Date(), username: nil, stats: .placeholder)
        }

        do {
            let stats = try await client.fetchStats(for: username)
            let cachedStats = stats.cachedStats
            sharedStore.saveCachedStats(cachedStats)
            return LeetTrackerEntry(date: Date(), username: stats.username, stats: cachedStats)
        } catch {
            return LeetTrackerEntry(
                date: Date(),
                username: username,
                stats: sharedStore.cachedStats ?? .placeholder
            )
        }
    }
}

struct LeetTrackerWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: LeetTrackerEntry

    var body: some View {
        Group {
            if let username = entry.username {
                switch family {
                case .systemMedium:
                    MediumWidgetView(username: username, stats: entry.stats)
                default:
                    SmallWidgetView(username: username, stats: entry.stats)
                }
            } else {
                EmptyWidgetView()
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

struct LeetTrackerWidget: Widget {
    let kind = "com.hyder.LeetTracker.widget"

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
    LeetTrackerEntry(date: Date(), username: "leetcode-user", stats: .placeholder)
}

private struct SmallWidgetView: View {
    let username: String
    let stats: CachedLeetCodeStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LeetTracker")
                .font(.headline)

            Spacer()

            Text("\(stats.totalSolved)")
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .contentTransition(.numericText())

            Text("solved")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(username)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

private struct MediumWidgetView: View {
    let username: String
    let stats: CachedLeetCodeStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetTracker")
                        .font(.headline)

                    Text(username)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(stats.totalSolved)")
                        .font(.title.weight(.semibold))

                    Text("solved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                DifficultyStatRow(title: "Easy", value: stats.easySolved)
                DifficultyStatRow(title: "Medium", value: stats.mediumSolved)
                DifficultyStatRow(title: "Hard", value: stats.hardSolved)
            }
        }
    }
}

private struct DifficultyStatRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text("\(value)")
                .font(.caption.weight(.semibold))
        }
    }
}

private struct EmptyWidgetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LeetTracker")
                .font(.headline)

            Spacer()

            Text("Set username in LeetTracker")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension CachedLeetCodeStats {
    static let placeholder = CachedLeetCodeStats(
        username: "leetcode-user",
        totalSolved: 128,
        easySolved: 54,
        mediumSolved: 61,
        hardSolved: 13,
        lastUpdated: Date()
    )
}
