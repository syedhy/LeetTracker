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
                StatPlaceholder(title: "Total", value: viewModel.statValue(\.totalSolved))
                StatPlaceholder(title: "Easy", value: viewModel.statValue(\.easySolved))
                StatPlaceholder(title: "Medium", value: viewModel.statValue(\.mediumSolved))
                StatPlaceholder(title: "Hard", value: viewModel.statValue(\.hardSolved))
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
