import Foundation

enum LeetTrackerWidgetConfiguration {
    static let kind = "com.hyder.LeetTracker.widget"
    static let refreshInterval: TimeInterval = 30 * 60
}

struct CachedLeetCodeStats: Codable, Equatable {
    let username: String
    let totalSolved: Int
    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int
    let lastUpdated: Date
}

struct SharedLeetTrackerSnapshot: Equatable {
    let username: String?
    let cachedStats: CachedLeetCodeStats?
    let lastUpdated: Date?
}

final class SharedLeetTrackerStore {
    static let appGroupIdentifier = "group.com.hyder.LeetTracker"

    private enum Keys {
        static let username = "leetcodeUsername"
        static let cachedStats = "cachedLeetCodeStats"
        static let lastUpdated = "lastUpdated"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults? = UserDefaults(suiteName: SharedLeetTrackerStore.appGroupIdentifier)) {
        self.userDefaults = userDefaults ?? .standard
    }

    var snapshot: SharedLeetTrackerSnapshot {
        SharedLeetTrackerSnapshot(
            username: username,
            cachedStats: cachedStats,
            lastUpdated: lastUpdated
        )
    }

    var username: String? {
        let storedUsername = userDefaults.string(forKey: Keys.username)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let storedUsername, !storedUsername.isEmpty else {
            return nil
        }

        return storedUsername
    }

    var cachedStats: CachedLeetCodeStats? {
        guard let data = userDefaults.data(forKey: Keys.cachedStats) else {
            return nil
        }

        return try? decoder.decode(CachedLeetCodeStats.self, from: data)
    }

    var lastUpdated: Date? {
        userDefaults.object(forKey: Keys.lastUpdated) as? Date
    }

    func saveUsername(_ username: String) {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        userDefaults.set(normalizedUsername, forKey: Keys.username)
        userDefaults.set(Date(), forKey: Keys.lastUpdated)
        synchronize()
    }

    func saveCachedStats(_ stats: CachedLeetCodeStats) {
        guard let data = try? encoder.encode(stats) else {
            return
        }

        userDefaults.set(data, forKey: Keys.cachedStats)
        userDefaults.set(stats.lastUpdated, forKey: Keys.lastUpdated)
        synchronize()
    }

    @discardableResult
    func synchronize() -> Bool {
        userDefaults.synchronize()
    }
}
