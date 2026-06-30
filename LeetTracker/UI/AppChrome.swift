import SwiftUI

struct AppSidebar: View {
    @Binding var selectedSection: AppSection
    @Binding var isSidebarVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                AppIconMark(size: 38, cornerRadius: 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetTracker")
                        .font(.headline.weight(.semibold))

                    Text("Practice OS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    withAnimation(.snappy(duration: 0.18)) {
                        isSidebarVisible = false
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                }
                .buttonStyle(DoodleIconButtonStyle(size: 34))
                .help("Hide sidebar")
            }
            .padding(.bottom, 8)

            VStack(spacing: 6) {
                ForEach(AppSection.allCases) { section in
                    SidebarSectionButton(
                        section: section,
                        selectedSection: $selectedSection
                    )
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Text("Auto Refresh")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColor.ink)
                        .frame(width: 8, height: 8)

                    Text(LeetTrackerWidgetConfiguration.refreshIntervalDescription)
                        .font(.callout.weight(.medium))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColor.line.opacity(0.42), lineWidth: 1.4)
            }
        }
        .padding(22)
        .frame(width: 236)
        .background(AppColor.paperWarm.opacity(0.88))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColor.line.opacity(0.18))
                .frame(width: 1.4)
        }
    }
}

struct SidebarSectionButton: View {
    let section: AppSection
    @Binding var selectedSection: AppSection
    @State private var isHovered = false

    private var isSelected: Bool {
        selectedSection == section
    }

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.16)) {
                selectedSection = section
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: section.systemImage)
                    .frame(width: 18)

                Text(section.rawValue)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .background(
                AppColor.ink.opacity(isSelected ? 0.1 : (isHovered ? 0.085 : 0)),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColor.ink)
                        .frame(width: 4, height: 22)
                }
            }
            .overlay {
                if isHovered, !isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColor.line.opacity(0.3), lineWidth: 1.15)
                }
            }
        }
        .buttonStyle(.plain)
        .font(.callout.weight(isSelected ? .semibold : .regular))
        .foregroundStyle(isSelected ? .primary : .secondary)
        .onHover { hovering in
            withAnimation(.snappy(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }
}

struct SidebarButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(
                isSelected ? AppColor.ink.opacity(configuration.isPressed ? 0.13 : 0.08) : .clear,
                in: RoundedRectangle(cornerRadius: 10)
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColor.ink)
                        .frame(width: 4, height: 22)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

struct FloatingSidebarToggle: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "sidebar.left")
        }
        .buttonStyle(DoodleIconButtonStyle(size: 42))
        .help("Show sidebar")
    }
}

struct StatusPill: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColor.paperWarm, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppColor.line.opacity(0.32), lineWidth: 1)
            }
    }
}

struct Panel<Content: View>: View {
    private let content: Content
    @State private var isHovered = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .doodlePanel(cornerRadius: 18, shadowOffset: 4)
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Text(value)
                .font(.callout.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }
}

struct EmptyPanelMessage: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(AppColor.paper)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(AppColor.ink.opacity(isEnabled ? (configuration.isPressed ? 0.74 : 1) : 0.42), in: RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(AppColor.paperWarm.opacity(configuration.isPressed ? 0.95 : 0.72), in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColor.line.opacity(0.46), lineWidth: 1.2)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

struct DoodleIconButtonStyle: ButtonStyle {
    let size: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(AppColor.ink)
            .frame(width: size, height: size)
            .background(AppColor.paper, in: Circle())
            .overlay {
                Circle()
                    .stroke(AppColor.ink.opacity(0.78), lineWidth: 1.6)
            }
            .shadow(color: AppColor.ink.opacity(0.07), radius: 3, x: 2, y: 2)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}

struct PracticeModePicker: View {
    @Binding var selectedMode: PracticeMode

    var body: some View {
        HStack(spacing: 8) {
            ForEach(PracticeMode.allCases) { mode in
                Button {
                    withAnimation(.snappy(duration: 0.16)) {
                        selectedMode = mode
                    }
                } label: {
                    Label(mode.rawValue, systemImage: mode.systemImage)
                        .frame(minWidth: 112)
                }
                .buttonStyle(PracticeModeButtonStyle(isSelected: selectedMode == mode))
            }

            Spacer(minLength: 0)
        }
    }
}

struct PracticeModeButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(isSelected ? AppColor.paper : AppColor.ink)
            .padding(.horizontal, 14)
            .frame(height: 42)
            .background(isSelected ? AppColor.ink : AppColor.paper, in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColor.ink.opacity(isSelected ? 1 : 0.5), lineWidth: 1.5)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}
