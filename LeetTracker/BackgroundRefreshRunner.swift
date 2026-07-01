import Darwin
import Foundation
import WidgetKit

enum BackgroundRefreshRunner {
    static let argument = "--background-refresh"



    static func refreshWidgetData() async -> RefreshResult {
        let store = SharedLeetTrackerStore()

        guard let username = store.username else {
            let errorMsg = "No username saved."
            store.saveBackgroundRefreshStatus(date: Date(), error: errorMsg)
            return RefreshResult(message: "LeetTracker background refresh skipped: \(errorMsg)", exitCode: EXIT_SUCCESS)
        }

        if
            let cachedStats = store.cachedStats,
            Date().timeIntervalSince(cachedStats.lastUpdated) < LeetTrackerWidgetConfiguration.refreshInterval
        {
            reloadWidgetTimelines()
            store.saveBackgroundRefreshStatus(date: Date(), error: nil)

            return RefreshResult(
                message: "LeetTracker background refresh skipped: cached stats are still fresh from \(cachedStats.lastUpdated).",
                exitCode: EXIT_SUCCESS
            )
        }

        do {
            let stats = try await LeetCodeClient().fetchStats(for: username)
            store.saveUsername(stats.username)
            store.saveCachedStats(stats.cachedStats)
            store.saveBackgroundRefreshStatus(date: Date(), error: nil)
            reloadWidgetTimelines()

            return RefreshResult(
                message: "LeetTracker background refresh updated \(stats.username): \(stats.totalSolved) solved.",
                exitCode: EXIT_SUCCESS
            )
        } catch {
            if let cachedStats = store.cachedStats {
                reloadWidgetTimelines()
                store.saveBackgroundRefreshStatus(date: Date(), error: error.localizedDescription)

                return RefreshResult(
                    message: "LeetTracker background refresh could not fetch fresh data. Kept cached stats from \(cachedStats.lastUpdated).",
                    exitCode: EXIT_SUCCESS
                )
            }

            store.saveBackgroundRefreshStatus(date: Date(), error: error.localizedDescription)
            return RefreshResult(
                message: "LeetTracker background refresh failed before any stats were cached: \(error.localizedDescription)",
                exitCode: EXIT_FAILURE
            )
        }
    }

    private static func reloadWidgetTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.kind)
        WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.streakKind)
    }

    private static func writeLog(_ message: String) {
        fputs("[\(Date())] \(message)\n", stderr)
    }
}

struct RefreshResult {
    let message: String
    let exitCode: Int32
}
