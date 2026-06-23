import SwiftUI

struct DashboardHeroBoard: View {
    let total: String
    let username: String
    let lastUpdated: String
    let focusTitle: String
    let focusDetail: String

    var body: some View {
        Panel {
            #if os(iOS)
            VStack(alignment: .leading, spacing: 22) {
                heroCopy
                scoreSheet
            }
            #else
            HStack(alignment: .center, spacing: 28) {
                heroCopy
                    .frame(maxWidth: .infinity, alignment: .leading)
                scoreSheet
                    .frame(minWidth: 300, idealWidth: 380, maxWidth: 460)
            }
            #endif
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 22) {
            #if os(iOS)
            HStack(alignment: .center, spacing: 8) {
                Text("Practice Lab")
                    .font(.system(.title, design: .rounded).weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                Spacer(minLength: 0)

                PracticePulseSketch()
                    .frame(width: 168, height: 128)
                    .scaleEffect(0.65)
                    .frame(width: 120, height: 90)
            }
            #else
            HStack(alignment: .center, spacing: 12) {
                Text("Practice Lab")
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                PracticePulseSketch()
                    .frame(width: 168, height: 128)
                    .padding(.leading, 2)
                    .scaleEffect(0.85)
            }
            #endif

            HStack(spacing: 10) {
                Text(username)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Circle()
                    .fill(AppColor.ink.opacity(0.42))
                    .frame(width: 5, height: 5)

                Text(lastUpdated)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }

    private var scoreSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text(total)
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text("solved")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(focusTint)
                    .frame(width: 42, height: 42)
                    .background(AppColor.paper, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(focusTint.opacity(0.6), lineWidth: 1.6)
                    }

                VStack(alignment: .leading, spacing: 5) {
                    Text(focusTitle)
                        .font(.headline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(focusDetail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(AppColor.paperWarm.opacity(0.54), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.line.opacity(0.28), lineWidth: 1.2)
        }
    }

    private var focusTint: Color {
        switch focusTitle {
        case "Add one Hard":
            return AppColor.hard
        case "Lean into Medium":
            return AppColor.medium
        case "Finish the goal":
            return AppColor.easy
        default:
            return AppColor.ink
        }
    }
}

struct PracticePulseSketch: View {
    var body: some View {
        ZStack {
            PracticeConnector()
                .stroke(
                    AppColor.ink.opacity(0.88),
                    style: StrokeStyle(lineWidth: 4.4, lineCap: .round, lineJoin: .round)
                )
                .drawingGroup()
                .frame(width: 140, height: 96)
                .offset(x: 12, y: 10)

            AppIconMark(size: 58, cornerRadius: 14)
                .rotationEffect(.degrees(-2))
                .offset(x: -38, y: -4)

            PracticeNode(size: 38, tint: AppColor.easy, systemImage: "checkmark")
                .offset(x: 42, y: -36)

            PracticeNode(size: 38, tint: AppColor.medium, systemImage: "arrow.up.right")
                .offset(x: 64, y: 16)

            PracticeNode(size: 38, tint: AppColor.hard, systemImage: "flame.fill")
                .offset(x: -12, y: 42)
        }
        .frame(width: 168, height: 128)
        .drawingGroup()
    }
}

struct PracticeNode: View {
    let size: CGFloat
    let tint: Color
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .black, design: .rounded))
            .foregroundStyle(AppColor.ink)
            .frame(width: size, height: size)
            .background(tint.opacity(0.88), in: Circle())
            .overlay {
                Circle()
                    .stroke(AppColor.ink, lineWidth: 2.6)
            }
            .shadow(color: AppColor.ink.opacity(0.12), radius: 0, x: 4, y: 4)
    }
}

struct PracticeConnector: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let hub = CGPoint(x: rect.minX + rect.width * 0.34, y: rect.minY + rect.height * 0.44)

        path.move(to: hub)
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.72, y: rect.minY + rect.height * 0.16),
            control1: CGPoint(x: rect.minX + rect.width * 0.46, y: rect.minY + rect.height * 0.30),
            control2: CGPoint(x: rect.minX + rect.width * 0.56, y: rect.minY + rect.height * 0.18)
        )

        path.move(to: hub)
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.86, y: rect.minY + rect.height * 0.58),
            control1: CGPoint(x: rect.minX + rect.width * 0.52, y: rect.minY + rect.height * 0.54),
            control2: CGPoint(x: rect.minX + rect.width * 0.68, y: rect.minY + rect.height * 0.52)
        )

        path.move(to: hub)
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.86),
            control1: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * 0.56),
            control2: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.minY + rect.height * 0.78)
        )

        return path
    }
}

struct DashboardCommandCenterPanel: View {
    let goalTitle: String
    let goalDetail: String
    let analyticsTitle: String
    let analyticsDetail: String
    let reminderTitle: String
    let reminderDetail: String
    let plannerTitle: String
    let plannerDetail: String
    let widgetTitle: String
    let widgetDetail: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    SectionHeader(title: "Quick Reads", systemImage: "sparkle.magnifyingglass")

                    Spacer()

                    Text("scan before practice")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }

                #if os(iOS)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                    DashboardSignalTile(title: "Target", value: goalTitle, detail: goalDetail, systemImage: "target", tint: AppColor.ink)
                    DashboardSignalTile(title: "Analytics", value: analyticsTitle, detail: analyticsDetail, systemImage: "chart.xyaxis.line", tint: AppColor.ink)
                    DashboardSignalTile(title: "Reminders", value: reminderTitle, detail: reminderDetail, systemImage: "bell.badge", tint: AppColor.medium)
                    DashboardSignalTile(title: "Planner", value: plannerTitle, detail: plannerDetail, systemImage: "calendar.badge.checkmark", tint: AppColor.ink)
                    DashboardSignalTile(title: "Widget", value: widgetTitle, detail: widgetDetail, systemImage: "square.grid.2x2", tint: AppColor.ink)
                }
                #else
                HStack(spacing: 10) {
                    DashboardSignalTile(
                        title: "Target",
                        value: goalTitle,
                        detail: goalDetail,
                        systemImage: "target",
                        tint: AppColor.ink
                    )

                    DashboardSignalTile(
                        title: "Analytics",
                        value: analyticsTitle,
                        detail: analyticsDetail,
                        systemImage: "chart.xyaxis.line",
                        tint: AppColor.ink
                    )

                    DashboardSignalTile(
                        title: "Reminders",
                        value: reminderTitle,
                        detail: reminderDetail,
                        systemImage: "bell.badge",
                        tint: AppColor.medium
                    )

                    DashboardSignalTile(
                        title: "Planner",
                        value: plannerTitle,
                        detail: plannerDetail,
                        systemImage: "calendar.badge.checkmark",
                        tint: AppColor.ink
                    )

                    DashboardSignalTile(
                        title: "Widget",
                        value: widgetTitle,
                        detail: widgetDetail,
                        systemImage: "square.grid.2x2",
                        tint: AppColor.ink
                    )
                }
                #endif
            }
        }
    }
}

struct DifficultyDashboardPanel: View {
    let rows: [DifficultyDistributionRow]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    SectionHeader(title: "Difficulty Mix", systemImage: "circle.grid.3x3.fill")

                    Spacer()

                    Text("public solved counts")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }

                DifficultyMixCards(rows: rows)
            }
        }
    }
}

struct DashboardSignalTile: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .frame(width: 28, height: 28)
                    .background(AppColor.paper, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(tint.opacity(0.58), lineWidth: 1.4)
                    }

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 102, alignment: .leading)
        .background(tint.opacity(tint == AppColor.ink ? 0.035 : 0.09), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(tint == AppColor.ink ? 0.2 : 0.44), lineWidth: 1.1)
        }
    }
}

struct TotalSolvedCard: View {
    let total: String
    let username: String
    let lastUpdated: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppColor.paper.opacity(0.76))
                        .lineLimit(1)

                    Text(lastUpdated)
                        .font(.caption)
                        .foregroundStyle(AppColor.paper.opacity(0.52))
                }

                Spacer()

                VStack(spacing: 5) {
                    Circle().fill(AppColor.easy)
                    Circle().fill(AppColor.medium)
                    Circle().fill(AppColor.hard)
                }
                .frame(width: 8, height: 30)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(total)
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColor.paper)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("solved")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColor.paper.opacity(0.62))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppColor.ink,
                    Color(red: 0.02, green: 0.02, blue: 0.018)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.line, lineWidth: 1.2)
        }
    }
}

struct DifficultyCard: View {
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
        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(tint.opacity(0.64), lineWidth: 1.2)
        }
    }
}

struct StatusPanel: View {
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
                    .foregroundStyle(AppColor.ink)
                    .padding(.top, 2)
            }

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.75), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColor.line.opacity(0.3), lineWidth: 1)
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)

            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.paperWarm.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.48), lineWidth: 1)
        }
    }
}
