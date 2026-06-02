import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("leetcodeUsername") private var savedUsername = ""
    @State private var username = ""
    @State private var statusMessage = "Enter a LeetCode username to prepare tracking."

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
            username = savedUsername
            if !savedUsername.isEmpty {
                statusMessage = "Ready to track \(savedUsername)."
            }
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
                TextField("username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveUsername)

                Button("Save", action: saveUsername)
                    .keyboardShortcut(.defaultAction)
                    .disabled(trimmedUsername.isEmpty)
            }
        }
    }

    private var placeholderStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats Preview")
                .font(.headline)

            HStack(spacing: 12) {
                StatPlaceholder(title: "Total", value: "--")
                StatPlaceholder(title: "Easy", value: "--")
                StatPlaceholder(title: "Medium", value: "--")
                StatPlaceholder(title: "Hard", value: "--")
            }
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)

            Text(statusMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveUsername() {
        let normalizedUsername = trimmedUsername

        guard !normalizedUsername.isEmpty else {
            statusMessage = "Enter a username before saving."
            return
        }

        savedUsername = normalizedUsername
        username = normalizedUsername
        statusMessage = "Saved \(normalizedUsername). Stats fetching is coming in a later phase."
        WidgetCenter.shared.reloadAllTimelines()
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
