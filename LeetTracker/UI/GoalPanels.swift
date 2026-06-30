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

                HStack(alignment: .bottom, spacing: 12) {
                    GoalField(title: "Target solved", text: $targetText, systemImage: "target", onSubmit: saveAction)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Weekly pace", systemImage: "calendar")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(weeklyDifficultyTotalText)
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(AppColor.brand)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }

                DifficultyGoalGrid(
                    easyText: $weeklyEasyTargetText,
                    mediumText: $weeklyMediumTargetText,
                    hardText: $weeklyHardTargetText,
                    projectedMixText: projectedMixText,
                    totalText: weeklyDifficultyTotalText,
                    onSubmit: saveAction
                )

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
        .onChange(of: weeklyEasyTargetText) { oldValue, newValue in
            enforceWeeklyLimit(fieldValue: &weeklyEasyTargetText, newValue: newValue)
        }
        .onChange(of: weeklyMediumTargetText) { oldValue, newValue in
            enforceWeeklyLimit(fieldValue: &weeklyMediumTargetText, newValue: newValue)
        }
        .onChange(of: weeklyHardTargetText) { oldValue, newValue in
            enforceWeeklyLimit(fieldValue: &weeklyHardTargetText, newValue: newValue)
        }
        .onChange(of: targetText) { oldValue, newValue in
            let maxTarget = Int(newValue) ?? 0
            let easy = Int(weeklyEasyTargetText) ?? 0
            let medium = Int(weeklyMediumTargetText) ?? 0
            let hard = Int(weeklyHardTargetText) ?? 0
            let sum = easy + medium + hard
            if sum > maxTarget {
                // If target drops below sum, zero out the hard/medium first as a simple fallback
                weeklyEasyTargetText = String(min(easy, maxTarget))
                weeklyMediumTargetText = String(min(medium, max(0, maxTarget - Int(weeklyEasyTargetText)!)))
                weeklyHardTargetText = String(min(hard, max(0, maxTarget - Int(weeklyEasyTargetText)! - Int(weeklyMediumTargetText)!)))
            }
        }
    }
    
    private func enforceWeeklyLimit(fieldValue: inout String, newValue: String) {
        if newValue.isEmpty { return }
        
        let maxTarget = Int(targetText) ?? 0
        let easy = Int(weeklyEasyTargetText) ?? 0
        let medium = Int(weeklyMediumTargetText) ?? 0
        let hard = Int(weeklyHardTargetText) ?? 0
        
        let sum = easy + medium + hard
        
        if sum > maxTarget {
            let otherTwo = sum - (Int(newValue) ?? 0)
            let allowed = maxTarget - otherTwo
            fieldValue = String(max(0, allowed))
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
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)
                .onSubmit {
                    onSubmit?()
                }
                #if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.done)
                #endif
                .onChange(of: text) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if newValue != filtered {
                        text = filtered
                    }
                }
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
    var onSubmit: (() -> Void)? = nil

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

            HStack(alignment: .top, spacing: 10) {
                DifficultyGoalField(title: "Easy", text: $easyText, tint: AppColor.easy, onSubmit: onSubmit)
                DifficultyGoalField(title: "Medium", text: $mediumText, tint: AppColor.medium, onSubmit: onSubmit)
                DifficultyGoalField(title: "Hard", text: $hardText, tint: AppColor.hard, onSubmit: onSubmit)
            }

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
    var onSubmit: (() -> Void)? = nil

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
                .frame(maxWidth: .infinity, alignment: .leading)
                .onSubmit {
                    onSubmit?()
                }
                #if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.done)
                #endif
                .onChange(of: text) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if newValue != filtered {
                        text = filtered
                    }
                }
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
                        .datePickerStyle(.compact)
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


