import SwiftUI

struct GoalEditorPanel: View {
    @Binding var targetText: String
    @Binding var weeklyTargetText: String
    @Binding var weeklyEasyTargetText: String
    @Binding var weeklyMediumTargetText: String
    @Binding var weeklyHardTargetText: String
    @Binding var remindersEnabled: Bool
    @Binding var reminderTime: Date

    let projectedMixText: String
    let statusText: String
    let saveAction: () -> Void

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Set Goal", systemImage: "slider.horizontal.3")

                #if os(iOS)
                HStack(alignment: .bottom, spacing: 12) {
                    GoalField(title: "Target solved", text: $targetText, systemImage: "target")
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Weekly pace", systemImage: "calendar")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(weeklyDifficultyTotalText)
                            .font(.title3.weight(.semibold))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                            .background(AppColor.paperWarm.opacity(0.58), in: RoundedRectangle(cornerRadius: 13))
                            .overlay {
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(AppColor.line.opacity(0.28), lineWidth: 1)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }

                DifficultyGoalGrid(
                    easyText: $weeklyEasyTargetText,
                    mediumText: $weeklyMediumTargetText,
                    hardText: $weeklyHardTargetText,
                    projectedMixText: projectedMixText,
                    totalText: weeklyDifficultyTotalText
                )
                #else
                GoalField(title: "Weekly pace", text: $weeklyTargetText, systemImage: "calendar")
                #endif

                ReminderGoalCard(
                    remindersEnabled: $remindersEnabled,
                    reminderTime: $reminderTime
                )

                HStack(alignment: .center, spacing: 10) {
                    Button(action: saveAction) {
                        Label("Save", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
    }

    private var weeklyDifficultyTotalText: String {
        let total = [
            Int(weeklyEasyTargetText.filter(\.isNumber)) ?? 0,
            Int(weeklyMediumTargetText.filter(\.isNumber)) ?? 0,
            Int(weeklyHardTargetText.filter(\.isNumber)) ?? 0
        ].reduce(0, +)

        guard total > 0 else {
            return "Set a weekly mix"
        }

        return "\(total)/week"
    }

}

struct GoalField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(AppColor.paperWarm.opacity(0.58), in: RoundedRectangle(cornerRadius: 13))
                .overlay {
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(AppColor.line.opacity(0.28), lineWidth: 1)
                }
        }
    }
}

struct DifficultyGoalGrid: View {
    @Binding var easyText: String
    @Binding var mediumText: String
    @Binding var hardText: String

    let projectedMixText: String
    let totalText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label("Weekly difficulty targets", systemImage: "list.bullet.rectangle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text(totalText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            #if os(iOS)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 3),
                alignment: .leading,
                spacing: 10
            ) {
                DifficultyGoalField(title: "Easy", text: $easyText, tint: AppColor.easy)
                DifficultyGoalField(title: "Medium", text: $mediumText, tint: AppColor.medium)
                DifficultyGoalField(title: "Hard", text: $hardText, tint: AppColor.hard)
            }
            #else
            HStack(alignment: .top, spacing: 10) {
                DifficultyGoalField(title: "Easy", text: $easyText, tint: AppColor.easy)
                DifficultyGoalField(title: "Medium", text: $mediumText, tint: AppColor.medium)
                DifficultyGoalField(title: "Hard", text: $hardText, tint: AppColor.hard)
            }
            #endif

            Text(projectedMixText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.48), in: RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColor.line.opacity(0.16), lineWidth: 1)
        }
    }
}

struct DifficultyGoalField: View {
    let title: String
    @Binding var text: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Circle()
                    .fill(tint)
                    .frame(width: 9, height: 9)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 13))
                .overlay {
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(tint.opacity(0.42), lineWidth: 1)
                }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct GoalWeekPreviewPanel: View {
    let title: String
    let subtitle: String
    let rows: [(String, String)]
    let nextSession: String
    let reminderText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "This Week", systemImage: "calendar.badge.checkmark")

                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColor.medium)
                        .frame(width: 42, height: 42)
                        .background(AppColor.paperWarm.opacity(0.85), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3.weight(.semibold))

                        Text(subtitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(alignment: .top, spacing: 10) {
                    GoalWeekMiniTile(title: "Next", value: nextSession, tint: AppColor.ink)
                    GoalWeekMiniTile(title: "Reminder", value: reminderText, tint: AppColor.medium)

                    ForEach(rows.prefix(2), id: \.0) { row in
                        GoalWeekMiniTile(title: row.0, value: row.1, tint: AppColor.ink)
                    }
                }
            }
        }
    }
}

struct GoalWeekMiniTile: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Circle()
                .fill(tint)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.callout.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .topLeading)
        .background(AppColor.paperWarm.opacity(0.54), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColor.line.opacity(0.16), lineWidth: 1)
        }
    }
}

struct ReminderGoalCard: View {
    @Binding var remindersEnabled: Bool
    @Binding var reminderTime: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Label("Practice reminders", systemImage: "bell.badge")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Toggle("", isOn: $remindersEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(remindersEnabled ? "Daily nudge" : "Reminders off")
                        .font(.callout.weight(.semibold))

                    Text(remindersEnabled ? "One reminder plus a Sunday reset." : "Turn on when you want a small pullback.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Nudge time")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .disabled(!remindersEnabled)
                }
            }
        }
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.48), in: RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColor.line.opacity(0.16), lineWidth: 1)
        }
    }
}

struct GoalPlanPanel: View {
    let title: String
    let subtitle: String
    let progress: Double
    let detailRows: [(String, String)]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Active Goal", systemImage: "target")

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ProgressView(value: progress)
                    .tint(AppColor.brand)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(detailRows, id: \.0) { row in
                        DetailRow(title: row.0, value: row.1)
                    }
                }
            }
        }
    }
}

struct PracticePlanPanel: View {
    let title: String
    let subtitle: String
    let rows: [(String, String)]
    let tint: Color

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Practice Plan", systemImage: "calendar.badge.checkmark")

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "list.clipboard.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(tint)
                        .frame(width: 42, height: 42)
                        .background(AppColor.paperWarm.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tint.opacity(0.52), lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(rows, id: \.0) { row in
                        DetailRow(title: row.0, value: row.1)
                    }
                }
            }
        }
    }
}

struct ReminderPlanPanel: View {
    let refreshText: String
    let remindersEnabled: Bool
    let reminderTimeText: String
    let weeklyReviewText: String
    let permissionText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Reminders", systemImage: "bell.badge")

                ReminderRow(
                    title: "Daily practice",
                    detail: remindersEnabled ? "Daily at \(reminderTimeText)" : "Off",
                    tint: remindersEnabled ? AppColor.easy : .secondary
                )
                ReminderRow(
                    title: "Weekly review",
                    detail: weeklyReviewText,
                    tint: remindersEnabled ? AppColor.brand : .secondary
                )
                ReminderRow(title: "Widget refresh", detail: refreshText, tint: AppColor.medium)

                Divider()

                DetailRow(title: "Permission", value: permissionText)
                DetailRow(title: "Copy style", value: "Gentle")
            }
        }
    }
}

struct ReminderRow: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.callout.weight(.semibold))

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

struct WidgetIdeaPanel: View {
    let title: String
    let detail: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    Image(systemName: systemImage)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                        .frame(width: 48, height: 48)
                        .background(AppColor.paperWarm.opacity(0.85), in: Circle())
                        .overlay {
                            Circle()
                                .stroke(tint.opacity(0.62), lineWidth: 1.6)
                        }

                    Spacer()

                    Text("Live")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.paper)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(AppColor.ink, in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(AppColor.line.opacity(0.28), lineWidth: 1)
                        }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title2.weight(.semibold))

                    Text(detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Capsule()
                    .fill(tint.opacity(0.82))
                    .frame(height: 7)
            }
        }
    }
}
