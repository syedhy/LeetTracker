import SwiftUI

struct WidgetStudioHeroPanel: View {
    let solvedText: String
    let username: String
    let refreshText: String

    var body: some View {
        Panel {
            #if os(iOS)
            VStack(alignment: .leading, spacing: 22) {
                heroCopy
                widgetStack
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            #else
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 24) {
                    heroCopy
                    Spacer(minLength: 12)
                    widgetStack
                }
                VStack(alignment: .leading, spacing: 22) {
                    heroCopy
                    widgetStack
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            #endif
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Text("3 live widgets")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppColor.paper)
                    .textCase(.uppercase)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(AppColor.ink, in: Capsule())

                Text(refreshText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Pin your practice loop")
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text("Progress and streaks are separate desktop cards so you can keep the useful signal visible without opening the app.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                WidgetHeroMetric(title: "Profile", value: username, tint: AppColor.ink)
                WidgetHeroMetric(title: "Solved", value: solvedText, tint: AppColor.easy)
            }
        }
        .frame(maxWidth: 560, alignment: .leading)
    }

    private var widgetStack: some View {
        ZStack {
            WidgetMiniPreviewCard(title: "Progress", value: solvedText, tint: AppColor.easy)
                .rotationEffect(.degrees(-4))
                .offset(x: -40, y: 18)

            WidgetMiniPreviewCard(title: "Streak", value: "Days", tint: AppColor.hard)
                .rotationEffect(.degrees(2))
                .offset(x: 40, y: -20)
        }
        .frame(width: 300, height: 210)
    }
}

struct WidgetHeroMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 9) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.callout.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColor.paperWarm.opacity(0.74), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.44), lineWidth: 1.2)
        }
    }
}

struct WidgetMiniPreviewCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                AppIconMark(size: 32, cornerRadius: 9)

                Spacer()

                Text(value)
                    .font(.title.weight(.black))
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.black))
                    .lineLimit(1)

                RoundedRectangle(cornerRadius: 3)
                    .fill(tint)
                    .frame(width: 72, height: 7)
            }
        }
        .padding(16)
        .frame(width: 172, height: 128, alignment: .leading)
        .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColor.ink.opacity(0.68), lineWidth: 2.2)
        }
        .shadow(color: AppColor.ink.opacity(0.12), radius: 8, x: 5, y: 6)
    }
}

struct WidgetSetupPanel: View {
    let refreshText: String
    let dataText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Desktop Setup", systemImage: "macwindow.on.rectangle")

                VStack(spacing: 12) {
                    WidgetSetupStep(number: "1", title: "Open widgets", detail: "Control-click the desktop and choose Edit Widgets.")
                    WidgetSetupStep(number: "2", title: "Search LeetTracker", detail: "Add Progress in small or medium size, plus the compact Streak widget.")
                    WidgetSetupStep(number: "3", title: "Let macOS refresh", detail: "\(refreshText). \(dataText)")
                }
            }
        }
    }
}

struct WidgetSetupStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.callout.weight(.black))
                .foregroundStyle(AppColor.paper)
                .frame(width: 28, height: 28)
                .background(AppColor.ink, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout.weight(.semibold))

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WidgetCatalogPanel: View {
    private let items = [
        WidgetCatalogItem(
            title: "Progress",
            detail: "Solved count, difficulty mix, and the last successful update.",
            value: "Live data",
            systemImage: "checkmark.seal.fill",
            assetImage: nil,
            tint: AppColor.easy
        ),
        WidgetCatalogItem(
            title: "Streak",
            detail: "A compact mascot card for the current public LeetCode streak.",
            value: "Small",
            systemImage: nil,
            assetImage: "StreakMascot",
            tint: AppColor.medium
        )
    ]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    SectionHeader(title: "Widget Set", systemImage: "square.grid.2x2")

                    Spacer()

                    Text("desktop set")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 14)], spacing: 14) {
                    ForEach(items) { item in
                        WidgetCatalogCard(item: item)
                    }
                }
            }
        }
    }
}

struct WidgetCatalogItem: Identifiable {
    let title: String
    let detail: String
    let value: String
    let systemImage: String?
    let assetImage: String?
    let tint: Color

    var id: String { title }
}

struct WidgetCatalogCard: View {
    let item: WidgetCatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Group {
                    if let asset = item.assetImage {
                        Image(asset)
                            .resizable()
                            .scaledToFit()
                    } else if let sys = item.systemImage {
                        Image(systemName: sys)
                    }
                }
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .frame(width: 42, height: 42)
                    .background(AppColor.paper, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(item.tint.opacity(0.62), lineWidth: 1.4)
                    }

                Spacer()

                Text(item.value)
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppColor.ink)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(item.tint.opacity(0.14), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(item.tint.opacity(0.44), lineWidth: 1)
                    }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.title3.weight(.black))
                    .lineLimit(1)

                Text(item.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 166, alignment: .leading)
        .background(item.tint.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(item.tint.opacity(0.36), lineWidth: 1.2)
        }
    }
}
