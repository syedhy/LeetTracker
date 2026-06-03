import SwiftUI

struct AppSidebar: View {
    @Binding var selectedSection: AppSection

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                AppIconMark()
                    .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text("LeetTracker")
                        .font(.headline.weight(.semibold))

                    Text("Practice OS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 8)

            VStack(spacing: 6) {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: section.systemImage)
                                .frame(width: 18)

                            Text(section.rawValue)
                                .lineLimit(1)

                            Spacer()
                        }
                    }
                    .buttonStyle(SidebarButtonStyle(isSelected: selectedSection == section))
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

                    Text("Every \(Int(LeetTrackerWidgetConfiguration.refreshInterval / 60)) min")
                        .font(.callout.weight(.medium))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.line.opacity(0.32), lineWidth: 1)
            }
        }
        .padding(20)
        .frame(width: 214)
        .background(AppColor.paperWarm.opacity(0.82))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColor.line.opacity(0.16))
                .frame(width: 1)
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
            .frame(height: 36)
            .background(
                isSelected ? AppColor.ink.opacity(configuration.isPressed ? 0.12 : 0.08) : .clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    Rectangle()
                        .fill(AppColor.ink)
                        .frame(width: 3, height: 18)
                }
            }
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

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.paper.opacity(0.94), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.line.opacity(0.32), lineWidth: 1.1)
            }
            .shadow(color: AppColor.ink.opacity(0.018), radius: 3, y: 2)
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
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(AppColor.ink.opacity(isEnabled ? (configuration.isPressed ? 0.74 : 1) : 0.42), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(AppColor.paperWarm.opacity(configuration.isPressed ? 0.95 : 0.72), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.line.opacity(0.36), lineWidth: 1)
            }
    }
}
