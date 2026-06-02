import Combine
import Foundation

@MainActor
final class LeetTrackerViewModel: ObservableObject {
    @Published var username = ""
    @Published private(set) var stats: LeetCodeStats?
    @Published private(set) var statusMessage = "Enter a LeetCode username to prepare tracking."
    @Published private(set) var isLoading = false

    private let client: LeetCodeClient
    private let sharedStore: SharedLeetTrackerStore

    init(
        client: LeetCodeClient = LeetCodeClient(),
        sharedStore: SharedLeetTrackerStore = SharedLeetTrackerStore()
    ) {
        self.client = client
        self.sharedStore = sharedStore
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var totalSolvedText: String {
        statText(stats?.totalSolved)
    }

    var easySolvedText: String {
        statText(stats?.easySolved)
    }

    var mediumSolvedText: String {
        statText(stats?.mediumSolved)
    }

    var hardSolvedText: String {
        statText(stats?.hardSolved)
    }

    func loadSavedState() {
        let snapshot = sharedStore.snapshot

        if let savedUsername = snapshot.username {
            username = savedUsername
            statusMessage = "Ready to track \(savedUsername)."
        }

        if let cachedStats = snapshot.cachedStats {
            stats = LeetCodeStats(cachedStats: cachedStats)
            statusMessage = "Loaded \(cachedStats.username). Updated \(formatted(cachedStats.lastUpdated))."
        }
    }

    func refreshStats() async -> Bool {
        let normalizedUsername = trimmedUsername

        guard !normalizedUsername.isEmpty else {
            statusMessage = LeetCodeProfileError.invalidUsername.localizedDescription
            return false
        }

        isLoading = true
        statusMessage = "Fetching stats for \(normalizedUsername)..."

        defer {
            isLoading = false
        }

        do {
            let freshStats = try await client.fetchStats(for: normalizedUsername)
            username = freshStats.username
            stats = freshStats
            sharedStore.saveUsername(freshStats.username)
            sharedStore.saveCachedStats(freshStats.cachedStats)
            statusMessage = "Updated \(freshStats.username). Last checked \(formatted(freshStats.lastUpdated))."
            return true
        } catch let error as LeetCodeProfileError {
            statusMessage = error.localizedDescription
            return false
        } catch {
            statusMessage = LeetCodeProfileError.networkUnavailable.localizedDescription
            return false
        }
    }

    private func statText(_ value: Int?) -> String {
        guard let value else {
            return "--"
        }

        return "\(value)"
    }

    private func formatted(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
}
