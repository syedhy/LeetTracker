import SwiftUI
import WidgetKit

struct LeetTrackerEntry: TimelineEntry {
    let date: Date
    let username: String?
}

struct LeetTrackerTimelineProvider: TimelineProvider {
    private let sharedStore = SharedLeetTrackerStore()

    func placeholder(in context: Context) -> LeetTrackerEntry {
        LeetTrackerEntry(date: Date(), username: "leetcode-user")
    }

    func getSnapshot(in context: Context, completion: @escaping (LeetTrackerEntry) -> Void) {
        completion(currentEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeetTrackerEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry], policy: .never))
    }

    private var currentEntry: LeetTrackerEntry {
        LeetTrackerEntry(date: Date(), username: sharedStore.username)
    }
}

struct LeetTrackerWidgetEntryView: View {
    let entry: LeetTrackerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LeetTracker")
                .font(.headline)

            Text(entry.username ?? "Set username in LeetTracker")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
    LeetTrackerEntry(date: Date(), username: "leetcode-user")
}
