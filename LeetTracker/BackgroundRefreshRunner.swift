import Darwin
import Foundation
import WidgetKit

enum BackgroundRefreshRunner {
    static let argument = "--background-refresh"

    static func runAndExitIfRequested() {
        guard CommandLine.arguments.contains(argument) else {
            return
        }

        let result = runSynchronously()
        writeLog(result.message)
        exit(result.exitCode)
    }

    private static func runSynchronously() -> RefreshResult {
        let semaphore = DispatchSemaphore(value: 0)
        let lock = NSLock()
        var result = RefreshResult(message: "LeetTracker background refresh timed out.", exitCode: EXIT_FAILURE)

        Task {
            let refreshResult = await refreshWidgetData()

            lock.lock()
            result = refreshResult
            lock.unlock()

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + .seconds(25))

        lock.lock()
        let finalResult = result
        lock.unlock()

        return finalResult
    }

    private static func refreshWidgetData() async -> RefreshResult {
        let store = SharedLeetTrackerStore()

        guard let username = store.username else {
            return RefreshResult(message: "LeetTracker background refresh skipped: no username saved.", exitCode: EXIT_SUCCESS)
        }

        do {
            let stats = try await LeetCodeClient().fetchStats(for: username)
            store.saveUsername(stats.username)
            store.saveCachedStats(stats.cachedStats)
            reloadWidgetTimelines()

            return RefreshResult(
                message: "LeetTracker background refresh updated \(stats.username): \(stats.totalSolved) solved.",
                exitCode: EXIT_SUCCESS
            )
        } catch {
            if let cachedStats = store.cachedStats {
                reloadWidgetTimelines()

                return RefreshResult(
                    message: "LeetTracker background refresh could not fetch fresh data. Kept cached stats from \(cachedStats.lastUpdated).",
                    exitCode: EXIT_SUCCESS
                )
            }

            return RefreshResult(
                message: "LeetTracker background refresh failed before any stats were cached: \(error.localizedDescription)",
                exitCode: EXIT_FAILURE
            )
        }
    }

    private static func reloadWidgetTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.kind)
    }

    private static func writeLog(_ message: String) {
        fputs("[\(Date())] \(message)\n", stderr)
    }
}

private struct RefreshResult {
    let message: String
    let exitCode: Int32
}
