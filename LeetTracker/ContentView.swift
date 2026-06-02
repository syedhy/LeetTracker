import Foundation
import SwiftUI
import WidgetKit

struct ContentView: View {
    @StateObject private var viewModel = LeetTrackerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            usernameSection
            placeholderStatsSection
            statusSection
        }
        .padding(28)
        .frame(minWidth: 520, idealWidth: 560, minHeight: 420)
        .onAppear {
            viewModel.loadSavedState()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LeetTracker")
                .font(.largeTitle.weight(.semibold))

            Text("Desktop widget setup")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var usernameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LeetCode Username")
                .font(.headline)

            HStack(spacing: 12) {
                TextField("username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveUsername)

                Button("Save", action: saveUsername)
                    .keyboardShortcut(.defaultAction)
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)
            }
        }
    }

    private var placeholderStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats Preview")
                .font(.headline)

            HStack(spacing: 12) {
                StatPlaceholder(title: "Total", value: viewModel.totalSolvedText)
                StatPlaceholder(title: "Easy", value: viewModel.easySolvedText)
                StatPlaceholder(title: "Medium", value: viewModel.mediumSolvedText)
                StatPlaceholder(title: "Hard", value: viewModel.hardSolvedText)
            }
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)

            Text(viewModel.statusMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func saveUsername() {
        Task {
            if await viewModel.refreshStats() {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

private struct StatPlaceholder: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title2.weight(.semibold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ContentView()
}

@MainActor
private final class LeetTrackerViewModel: ObservableObject {
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
            if username.isEmpty {
                username = cachedStats.username
            }

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
            showCachedStatsAfterFailure(error)
            return false
        } catch {
            showCachedStatsAfterFailure(.networkUnavailable)
            return false
        }
    }

    private func showCachedStatsAfterFailure(_ error: LeetCodeProfileError) {
        if let cachedStats = sharedStore.cachedStats {
            stats = LeetCodeStats(cachedStats: cachedStats)

            if trimmedUsername.isEmpty {
                username = cachedStats.username
            }

            statusMessage = "\(error.localizedDescription) Showing saved stats from \(formatted(cachedStats.lastUpdated))."
        } else {
            statusMessage = "\(error.localizedDescription) No saved stats yet."
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
