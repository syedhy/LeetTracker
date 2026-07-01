import Foundation

enum LeetTrackerWidgetConfiguration {
    static let kind = "com.hyder.LeetTracker.widget"
    static let streakKind = "com.hyder.LeetTracker.widget.streak"
    static let refreshInterval: TimeInterval = 2 * 60 * 60

    static var refreshIntervalDescription: String {
        let minutes = Int(refreshInterval / 60)

        if minutes >= 60, minutes.isMultiple(of: 60) {
            let hours = minutes / 60
            return hours == 1 ? "About every hour" : "About every \(hours) hours"
        }

        return "Every \(minutes) min"
    }
}

struct CachedLeetCodeStats: Codable, Equatable {
    let username: String
    let totalSolved: Int
    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int
    let currentStreak: Int?
    let totalActiveDays: Int?
    let lastUpdated: Date
}

struct SharedGoalSettings: Codable, Equatable {
    var targetSolved: Int
    var weeklyTarget: Int
    var weeklyEasyTarget: Int?
    var weeklyMediumTarget: Int?
    var weeklyHardTarget: Int?
    var remindersEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var updatedAt: Date

    static let `default` = SharedGoalSettings(
        targetSolved: 50,
        weeklyTarget: 5,
        weeklyEasyTarget: 1,
        weeklyMediumTarget: 3,
        weeklyHardTarget: 1,
        remindersEnabled: false,
        reminderHour: 19,
        reminderMinute: 0,
        updatedAt: Date()
    )
}

struct SharedLeetTrackerSnapshot: Equatable {
    let username: String?
    let cachedStats: CachedLeetCodeStats?
    let lastUpdated: Date?
    let goalSettings: SharedGoalSettings
    let hasGoalSettings: Bool
    let lastBackgroundRefreshDate: Date?
    let lastBackgroundRefreshError: String?
}

final class SharedLeetTrackerStore {
    static let appGroupIdentifier = "group.com.hyder.LeetTracker"

    private static let storeFileName = "LeetTrackerSharedStore.json"
    private static let legacyPreferencesPath = "Library/Preferences/\(appGroupIdentifier).plist"

    private let storeURL: URL
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.storeURL = Self.resolveStoreURL(fileManager: fileManager)
    }

    var snapshot: SharedLeetTrackerSnapshot {
        let payload = loadPayload()
        let normalizedUsername = payload.username?.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedUsername = normalizedUsername?.isEmpty == false ? normalizedUsername : nil

        return SharedLeetTrackerSnapshot(
            username: savedUsername,
            cachedStats: payload.cachedStats,
            lastUpdated: payload.lastUpdated,
            goalSettings: payload.goalSettings ?? .default,
            hasGoalSettings: payload.goalSettings != nil,
            lastBackgroundRefreshDate: payload.lastBackgroundRefreshDate,
            lastBackgroundRefreshError: payload.lastBackgroundRefreshError
        )
    }

    var username: String? {
        let storedUsername = loadPayload().username?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let storedUsername, !storedUsername.isEmpty else {
            return nil
        }

        return storedUsername
    }

    var cachedStats: CachedLeetCodeStats? {
        loadPayload().cachedStats
    }

    var lastUpdated: Date? {
        loadPayload().lastUpdated
    }

    var goalSettings: SharedGoalSettings {
        loadPayload().goalSettings ?? .default
    }

    func saveUsername(_ username: String) {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        var payload = loadPayload()
        payload.username = normalizedUsername
        payload.lastUpdated = Date()
        savePayload(payload)
    }

    func saveCachedStats(_ stats: CachedLeetCodeStats) {
        var payload = loadPayload()
        payload.username = stats.username
        payload.cachedStats = stats
        payload.lastUpdated = stats.lastUpdated
        savePayload(payload)
    }

    func saveGoalSettings(_ settings: SharedGoalSettings) {
        var payload = loadPayload()
        payload.goalSettings = settings
        savePayload(payload)
    }

    func saveBackgroundRefreshStatus(date: Date, error: String?) {
        var payload = loadPayload()
        payload.lastBackgroundRefreshDate = date
        payload.lastBackgroundRefreshError = error
        savePayload(payload)
    }

    @discardableResult
    func synchronize() -> Bool {
        true
    }

    private static func resolveStoreURL(fileManager: FileManager) -> URL {
        let fallbackBaseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let baseURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
            ?? fallbackBaseURL.appendingPathComponent("LeetTracker", isDirectory: true)

        return baseURL.appendingPathComponent(storeFileName)
    }

    private func loadPayload() -> SharedLeetTrackerPayload {
        if
            let data = try? Data(contentsOf: storeURL),
            let payload = try? decoder.decode(SharedLeetTrackerPayload.self, from: data)
        {
            return payload
        }

        if let legacyPayload = loadLegacyPayload() {
            savePayload(legacyPayload)
            return legacyPayload
        }

        return SharedLeetTrackerPayload()
    }

    private func savePayload(_ payload: SharedLeetTrackerPayload) {
        guard let data = try? encoder.encode(payload) else {
            return
        }

        do {
            try fileManager.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            return
        }
    }

    private func loadLegacyPayload() -> SharedLeetTrackerPayload? {
        let preferencesURL = storeURL.deletingLastPathComponent()
            .appendingPathComponent(Self.legacyPreferencesPath)

        guard
            let data = try? Data(contentsOf: preferencesURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
            let preferences = plist as? [String: Any]
        else {
            return nil
        }

        let username = (preferences["leetcodeUsername"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let cachedStatsData = preferences["cachedLeetCodeStats"] as? Data
        let cachedStats = cachedStatsData.flatMap { try? decoder.decode(CachedLeetCodeStats.self, from: $0) }
        let lastUpdated = (preferences["lastUpdated"] as? Date) ?? cachedStats?.lastUpdated

        guard username?.isEmpty == false || cachedStats != nil || lastUpdated != nil else {
            return nil
        }

        return SharedLeetTrackerPayload(
            username: username?.isEmpty == false ? username : cachedStats?.username,
            cachedStats: cachedStats,
            lastUpdated: lastUpdated
        )
    }
}

private struct SharedLeetTrackerPayload: Codable, Equatable {
    var username: String?
    var cachedStats: CachedLeetCodeStats?
    var lastUpdated: Date?
    var goalSettings: SharedGoalSettings?
    var lastBackgroundRefreshDate: Date?
    var lastBackgroundRefreshError: String?
}
