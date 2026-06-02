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
        WidgetContainer {
            if let username = entry.username {
                switch family {
                case .systemMedium:
                    MediumWidgetView(username: username, stats: entry.stats)
                default:
                    SmallWidgetView(username: username, stats: entry.stats)
                }
            } else {
                WidgetEmptyStateView(message: "Set username in LeetTracker")
            }
        }
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
        VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
            Text("LeetTracker")
                .font(LTWidgetTypography.title)

            Spacer()

            Text("\(stats.totalSolved)")
                .font(LTWidgetTypography.primaryNumber)
                .contentTransition(.numericText())

            Text("solved")
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.secondary)

            Text(username)
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.secondary)
                .lineLimit(1)
        }
    }
}

private struct MediumWidgetView: View {
    let username: String
    let stats: CachedLeetCodeStats

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.large) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: LTWidgetSpacing.xSmall) {
                    Text("LeetTracker")
                        .font(LTWidgetTypography.title)

                    Text(username)
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: LTWidgetSpacing.xSmall) {
                    Text("\(stats.totalSolved)")
                        .font(LTWidgetTypography.mediumNumber)

                    Text("solved")
                        .font(LTWidgetTypography.label)
                        .foregroundStyle(LTWidgetColor.secondary)
                }
            }

            VStack(spacing: LTWidgetSpacing.medium) {
                WidgetStatRow(title: "Easy", value: stats.easySolved)
                WidgetStatRow(title: "Medium", value: stats.mediumSolved)
                WidgetStatRow(title: "Hard", value: stats.hardSolved)
            }
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
