import SwiftUI
import WidgetKit

struct LeetTrackerEntry: TimelineEntry {
    let date: Date
}

struct LeetTrackerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LeetTrackerEntry {
        LeetTrackerEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (LeetTrackerEntry) -> Void) {
        completion(LeetTrackerEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeetTrackerEntry>) -> Void) {
        completion(Timeline(entries: [LeetTrackerEntry(date: Date())], policy: .never))
    }
}

struct LeetTrackerWidgetEntryView: View {
    let entry: LeetTrackerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LeetTracker")
                .font(.headline)

            Text("Widget ready")
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
    LeetTrackerEntry(date: Date())
}
