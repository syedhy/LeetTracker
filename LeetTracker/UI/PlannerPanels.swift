import SwiftUI

enum PlannerDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var tint: Color {
        switch self {
        case .easy:
            return AppColor.easy
        case .medium:
            return AppColor.medium
        case .hard:
            return AppColor.hard
        }
    }

    var sessionTitle: String {
        switch self {
        case .easy:
            return "Warm-up pattern"
        case .medium:
            return "Main practice block"
        case .hard:
            return "Deep study session"
        }
    }

    var sessionDetail: String {
        switch self {
        case .easy:
            return "Solve cleanly, then name the pattern."
        case .medium:
            return "Solve, review the tradeoffs, and record the key idea."
        case .hard:
            return "Study one difficult pattern without rushing the finish."
        }
    }
}

struct PlannerSession: Identifiable {
    let id: String
    let date: Date
    let difficulty: PlannerDifficulty
    let ordinal: Int

    var dayText: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    var dateText: String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }
}

enum WeeklyPlannerFactory {
    static func makeSessions(
        easy: Int,
        medium: Int,
        hard: Int,
        referenceDate: Date = Date()
    ) -> [PlannerSession] {
        var orderedDifficulties = difficultySequence(easy: easy, medium: medium, hard: hard)
        if orderedDifficulties.count > 21 {
            orderedDifficulties = Array(orderedDifficulties.prefix(21))
        }
        let weekStart = startOfWeek(containing: referenceDate)
        let weekID = weekIdentifier(for: referenceDate)
        let count = orderedDifficulties.count

        return orderedDifficulties.enumerated().map { index, difficulty in
            let dayOffset: Int

            if count <= 1 {
                dayOffset = 2
            } else {
                dayOffset = Int((Double(index) * 6 / Double(count - 1)).rounded())
            }

            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
            return PlannerSession(
                id: "\(weekID)-\(difficulty.rawValue)-\(index)",
                date: date,
                difficulty: difficulty,
                ordinal: index + 1
            )
        }
    }

    static func weekTitle(for date: Date = Date()) -> String {
        let start = startOfWeek(containing: date)
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
        let startText = start.formatted(.dateTime.month(.abbreviated).day())
        let endText = end.formatted(.dateTime.month(.abbreviated).day())
        return "\(startText) - \(endText)"
    }

    static func weekIdentifier(for date: Date = Date()) -> String {
        let start = startOfWeek(containing: date)
        return start.formatted(.iso8601.year().month().day())
    }

    private static func startOfWeek(containing date: Date) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysSinceMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysSinceMonday, to: startOfDay) ?? startOfDay
    }

    private static func difficultySequence(easy: Int, medium: Int, hard: Int) -> [PlannerDifficulty] {
        var remaining: [PlannerDifficulty: Int] = [
            .easy: max(0, easy),
            .medium: max(0, medium),
            .hard: max(0, hard)
        ]
        let pattern: [PlannerDifficulty] = [.easy, .medium, .medium, .hard]
        var sequence: [PlannerDifficulty] = []

        while remaining.values.reduce(0, +) > 0 {
            var addedInPass = false

            for difficulty in pattern where (remaining[difficulty] ?? 0) > 0 {
                sequence.append(difficulty)
                remaining[difficulty, default: 0] -= 1
                addedInPass = true
            }

            if !addedInPass {
                break
            }
        }

        return sequence
    }
}

struct PlannerOverviewPanel: View {
    let weekTitle: String
    let completedCount: Int
    let sessionCount: Int
    let nextSessionText: String
    let progress: Double
    let resetAction: () -> Void

    var body: some View {
        Panel {
            #if os(iOS)
            VStack(alignment: .leading, spacing: 20) {
                overviewCopy
                progressSummary
            }
            #else
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 24) {
                    overviewCopy
                    Spacer(minLength: 16)
                    progressSummary
                }
                VStack(alignment: .leading, spacing: 20) {
                    overviewCopy
                    progressSummary
                }
            }
            #endif
        }
    }

    private var overviewCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Weekly Practice Board", systemImage: "calendar.badge.checkmark")

            Text(weekTitle)
                .font(.largeTitle.weight(.semibold))

            Text(nextSessionText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: resetAction) {
                Label("Reset checkmarks", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .disabled(completedCount == 0)
        }
    }

    private var progressSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text("\(completedCount)")
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .monospacedDigit()

                Text("of \(sessionCount) sessions")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(AppColor.ink)

            Text(sessionCount == 0 ? "Set weekly difficulty targets to generate a plan." : "Check off sessions as you finish them.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 260, idealWidth: 340, maxWidth: 420, alignment: .leading)
    }
}

struct WeeklyPlannerBoard: View {
    let sessions: [PlannerSession]
    let completedIDs: Set<String>
    let toggleAction: (String) -> Void

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "This Week", systemImage: "rectangle.grid.2x2")

                if sessions.isEmpty {
                    EmptyPanelMessage(
                        title: "No sessions planned",
                        message: "Set at least one weekly difficulty target in Goals to build the board."
                    )
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 210), spacing: 12)],
                        alignment: .leading,
                        spacing: 12
                    ) {
                        ForEach(sessions) { session in
                            PlannerSessionCard(
                                session: session,
                                isCompleted: completedIDs.contains(session.id),
                                toggleAction: { toggleAction(session.id) }
                            )
                        }
                    }
                }
            }
        }
    }
}

struct PlannerSessionCard: View {
    let session: PlannerSession
    let isCompleted: Bool
    let toggleAction: () -> Void

    var body: some View {
        Button(action: toggleAction) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(session.dayText)
                            .font(.headline)

                        Text(session.dateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(isCompleted ? AppColor.ink : .secondary)
                }

                HStack(spacing: 7) {
                    Circle()
                        .fill(session.difficulty.tint)
                        .frame(width: 9, height: 9)

                    Text(session.difficulty.rawValue)
                        .font(.caption.weight(.semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.difficulty.sessionTitle)
                        .font(.callout.weight(.semibold))
                        .strikethrough(isCompleted, color: AppColor.graphite)

                    Text(session.difficulty.sessionDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 164, alignment: .topLeading)
            .background(
                isCompleted ? AppColor.paperWarm.opacity(0.38) : AppColor.paperWarm.opacity(0.68),
                in: RoundedRectangle(cornerRadius: 15)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isCompleted ? AppColor.line.opacity(0.16) : AppColor.line.opacity(0.3), lineWidth: 1)
            }
            .animation(.easeOut(duration: 0.16), value: isCompleted)
        }
        .buttonStyle(.plain)
    }
}


