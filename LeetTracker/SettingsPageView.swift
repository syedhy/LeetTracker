import SwiftUI

struct SettingsPageView: View {
    @ObservedObject var viewModel: LeetTrackerViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                pageHeader(
                    title: "Settings",
                    subtitle: "Profile, refresh, cache, and local data controls.",
                    systemImage: "gearshape"
                )

                #if os(iOS)
                VStack(spacing: 20) {
                    setupSection
                    dataHealthSection
                }
                #else
                VStack(spacing: 20) {
                    HStack(alignment: .top, spacing: 20) {
                        setupSection
                            .frame(minWidth: 280, maxWidth: .infinity)

                        dataHealthSection
                            .frame(minWidth: 300, idealWidth: 360, maxWidth: 420)
                    }
                    backgroundRefreshSection
                }
                #endif

                privacyEthicsSection
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func pageHeader(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.ink)
                .frame(width: 44, height: 44)
                .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.ink, lineWidth: 1.5)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var setupSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Profile", systemImage: "person.crop.circle")

                VStack(alignment: .leading, spacing: 8) {
                    Text("LeetCode Username")
                        .font(.headline)

                    TextField("username", text: $viewModel.username)
                        .textFieldStyle(.plain)
                        .font(.body)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled(true)
                        .padding(.horizontal, 13)
                        .frame(height: 38)
                        .background(AppColor.paperWarm.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColor.line.opacity(0.5), lineWidth: 1)
                        }
                        .onSubmit(viewModel.refreshStatsAndReloadWidgets)
                }

                HStack(spacing: 10) {
                    Button(action: viewModel.refreshStatsAndReloadWidgets) {
                        Label("Save", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .keyboardShortcut(.defaultAction)
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)

                    Button(action: viewModel.refreshStatsAndReloadWidgets) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    .disabled(viewModel.trimmedUsername.isEmpty || viewModel.isLoading)
                }

                Divider()

                StatusPanel(message: viewModel.statusMessage, isLoading: viewModel.isLoading)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dataHealthSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Data Health", systemImage: "waveform.path.ecg")

                DetailRow(title: "Cache", value: viewModel.cacheStatusText)
                DetailRow(title: "Auto refresh", value: viewModel.refreshCadenceText)
                DetailRow(title: "Background", value: viewModel.isBackgroundRefreshInstalled ? "Installed" : "Not Installed")
            }
        }
    }

    #if os(macOS)
    private var backgroundRefreshSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Background Refresh", systemImage: "arrow.triangle.2.circlepath")

                Text("Enable background refresh to allow LeetTracker to update widgets about every 2 hours even when the app is completely closed. This installs a lightweight background task.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                DetailRow(title: "Status", value: viewModel.backgroundRefreshStatusMessage)
                if let lastRun = viewModel.lastBackgroundRefreshDate {
                    DetailRow(title: "Last Run", value: lastRun.formatted())
                }
                if let lastError = viewModel.lastBackgroundRefreshError {
                    DetailRow(title: "Last Error", value: lastError)
                }

                HStack(spacing: 12) {
                    if viewModel.isBackgroundRefreshInstalled {
                        Button(action: viewModel.uninstallBackgroundRefresh) {
                            Label("Disable", systemImage: "xmark.circle")
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                    } else {
                        Button(action: viewModel.installBackgroundRefresh) {
                            Label("Enable Background Refresh", systemImage: "bolt.fill")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                    }
                }
            }
        }
    }
    #endif

    private var privacyEthicsSection: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Privacy & Ethics", systemImage: "hand.raised")

                DetailRow(title: "LeetCode data", value: "Public solved counts only")
                DetailRow(title: "Credentials", value: "Never requested")
                DetailRow(title: "Affiliation", value: "Independent app")

                Text("Use a username you own or have permission to track. LeetTracker keeps analytics local, avoids private account data, and refreshes at a low frequency.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
