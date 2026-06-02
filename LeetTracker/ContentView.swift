import Foundation
import SwiftUI
import WidgetKit

struct ContentView: View {
    @StateObject private var viewModel = LeetTrackerViewModel()

    var body: some View {
        ZStack {
            AppSurfaceBackground()

            VStack(alignment: .leading, spacing: 24) {
                header

                HStack(alignment: .top, spacing: 20) {
                    statsSection
                    setupSection
                }
            }
            .padding(28)
        }
        .frame(minWidth: 760, idealWidth: 860, minHeight: 520)
        .onAppear {
            viewModel.loadSavedState()
            requestWidgetReload()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            AppIconMark()

            VStack(alignment: .leading, spacing: 4) {
                Text("LeetTracker")
                    .font(.largeTitle.weight(.semibold))

                Text("Desktop widget setup")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusPill(
                title: viewModel.isLoading ? "Syncing" : "Ready",
                systemImage: viewModel.isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill",
                tint: viewModel.isLoading ? .orange : .green
            )
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "Progress", systemImage: "chart.bar.xaxis")

            TotalSolvedCard(
                total: viewModel.totalSolvedText,
                username: viewModel.displayUsername,
                lastUpdated: viewModel.lastUpdatedText
            )

            HStack(spacing: 12) {
                DifficultyCard(title: "Easy", value: viewModel.easySolvedText, tint: AppColor.easy)
                DifficultyCard(title: "Medium", value: viewModel.mediumSolvedText, tint: AppColor.medium)
                DifficultyCard(title: "Hard", value: viewModel.hardSolvedText, tint: AppColor.hard)
            }
        }
        .frame(minWidth: 330, maxWidth: .infinity)
    }

    private var setupSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Setup", systemImage: "person.crop.circle")

                VStack(alignment: .leading, spacing: 8) {
                    Text("LeetCode Username")
                        .font(.headline)

                    TextField("username", text: $viewModel.username)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(.horizontal, 13)
                        .frame(height: 38)
                        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.quaternary, lineWidth: 1)
                        }
                        .onSubmit(saveUsername)
                }

                HStack(spacing: 10) {
                    Button(action: saveUsername) {
                        Label("Save", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .keyboardShortcut(.defaultAction)
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)

                    Button(action: refreshStats) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)
                }

                Divider()

                StatusPanel(message: viewModel.statusMessage, isLoading: viewModel.isLoading)
            }
        }
        .frame(width: 320)
    }

    private func saveUsername() {
        fetchStatsAndRequestWidgetReload()
    }

    private func refreshStats() {
        fetchStatsAndRequestWidgetReload()
    }

    private func fetchStatsAndRequestWidgetReload() {
        Task {
            if await viewModel.refreshStats() {
                let requestedAt = Date()
                requestWidgetReload()
                viewModel.markWidgetReloadRequested(at: requestedAt)
            }
        }
    }

    private func requestWidgetReload() {
        WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.kind)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private enum AppColor {
    static let brand = Color(red: 0.22, green: 0.58, blue: 0.98)
    static let easy = Color(red: 0.18, green: 0.73, blue: 0.38)
    static let medium = Color(red: 0.95, green: 0.58, blue: 0.08)
    static let hard = Color(red: 0.92, green: 0.25, blue: 0.42)
}

private struct AppSurfaceBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .controlBackgroundColor).opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct AppIconMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.brand.gradient)

            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 48, height: 48)
        .shadow(color: AppColor.brand.opacity(0.28), radius: 16, y: 8)
    }
}

private struct StatusPill: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

private struct Panel<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.quaternary, lineWidth: 1)
            }
    }
}

private struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

private struct TotalSolvedCard: View {
    let total: String
    let username: String
    let lastUpdated: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(1)

                    Text(lastUpdated)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.brand)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(total)
                    .font(.system(size: 58, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("solved")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.13),
                    Color(red: 0.04, green: 0.06, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
    }
}

private struct DifficultyCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 10, height: 10)

            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
    }
}

private struct StatusPanel: View {
    let message: String
    let isLoading: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 2)
            } else {
                Image(systemName: "info.circle.fill")
                    .font(.body)
                    .foregroundStyle(AppColor.brand)
                    .padding(.top, 2)
            }

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(AppColor.brand.opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 0.42), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(.quaternary.opacity(configuration.isPressed ? 0.9 : 0.62), in: RoundedRectangle(cornerRadius: 10))
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

    var displayUsername: String {
        if let username = stats?.username, !username.isEmpty {
            return username
        }

        if !trimmedUsername.isEmpty {
            return trimmedUsername
        }

        return "No profile selected"
    }

    var lastUpdatedText: String {
        guard let lastUpdated = stats?.lastUpdated else {
            return "Not synced yet"
        }

        return "Updated \(formatted(lastUpdated))"
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

    func markWidgetReloadRequested(at date: Date) {
        guard let stats else {
            return
        }

        sharedStore.synchronize()
        statusMessage = "Updated \(stats.username). Widget reload requested at \(formatted(date)). Saved \(stats.totalSolved) solved."
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
