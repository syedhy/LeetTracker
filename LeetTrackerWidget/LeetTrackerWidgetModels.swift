import Foundation
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

struct WidgetStatsSnapshot: Equatable {
    let username: String
    let totalSolved: Int
    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int
    let lastUpdated: Date
}

extension WidgetStatsSnapshot {
    init(cachedStats: CachedLeetCodeStats) {
        self.init(
            username: cachedStats.username,
            totalSolved: cachedStats.totalSolved,
            easySolved: cachedStats.easySolved,
            mediumSolved: cachedStats.mediumSolved,
            hardSolved: cachedStats.hardSolved,
            lastUpdated: cachedStats.lastUpdated
        )
    }

    static let placeholder = WidgetStatsSnapshot(
        username: "leetcode-user",
        totalSolved: 128,
        easySolved: 54,
        mediumSolved: 61,
        hardSolved: 13,
        lastUpdated: Date()
    )
}
