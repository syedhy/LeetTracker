import SwiftUI

struct GoalEditorPanel: View {
    @Binding var targetText: String
    @Binding var weeklyTargetText: String
    @Binding var remindersEnabled: Bool
    @Binding var reminderTime: Date

    let statusText: String
    let saveAction: () -> Void

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Set Goal", systemImage: "slider.horizontal.3")

                VStack(alignment: .leading, spacing: 12) {
                    GoalField(title: "Target solved", text: $targetText, systemImage: "target")
                    GoalField(title: "Weekly target", text: $weeklyTargetText, systemImage: "calendar")

                    Toggle(isOn: $remindersEnabled) {
                        Label("Practice reminder", systemImage: "bell.badge")
                    }
                    .toggleStyle(.switch)

                    DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .disabled(!remindersEnabled)
                }

                HStack(spacing: 10) {
                    Button(action: saveAction) {
                        Label("Save Goal", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
        }
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
                .background(AppColor.paperWarm.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.line.opacity(0.5), lineWidth: 1)
                }
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

struct ReminderPlanPanel: View {
    let refreshText: String
    let remindersEnabled: Bool
    let reminderTimeText: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Reminders", systemImage: "bell.badge")

                ReminderRow(
                    title: "Daily practice",
                    detail: remindersEnabled ? reminderTimeText : "Off",
                    tint: remindersEnabled ? AppColor.easy : .secondary
                )
                ReminderRow(title: "Weekly review", detail: "Summarize progress and reset plan", tint: AppColor.brand)
                ReminderRow(title: "Widget refresh", detail: refreshText, tint: AppColor.medium)

                Divider()

                DetailRow(title: "Quiet hours", value: "Not set")
                DetailRow(title: "Notification style", value: "Gentle")
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
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(AppColor.paperWarm.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(tint.opacity(0.52), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3.weight(.semibold))

                    Text(detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
