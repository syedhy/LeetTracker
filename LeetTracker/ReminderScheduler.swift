import Foundation
import UserNotifications

struct ReminderScheduleResult: Equatable {
    let statusText: String
    let permissionText: String
}

enum ReminderSchedulerError: LocalizedError {
    case notificationsDenied

    var errorDescription: String? {
        switch self {
        case .notificationsDenied:
            return "Notifications are off in macOS settings."
        }
    }
}

final class ReminderScheduler {
    private let notificationCenter: UNUserNotificationCenter

    private enum Identifier {
        static let dailyPractice = "com.hyder.LeetTracker.reminder.dailyPractice"
        static let weeklyReview = "com.hyder.LeetTracker.reminder.weeklyReview"
    }

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    func apply(
        settings: SharedGoalSettings,
        username: String,
        weeklyMix: String
    ) async throws -> ReminderScheduleResult {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            Identifier.dailyPractice,
            Identifier.weeklyReview
        ])

        guard settings.remindersEnabled else {
            return ReminderScheduleResult(
                statusText: "Reminders turned off.",
                permissionText: "Notifications disabled by choice."
            )
        }

        let authorized = try await requestAuthorizationIfNeeded()

        guard authorized else {
            throw ReminderSchedulerError.notificationsDenied
        }

        try await scheduleDailyPractice(settings: settings, username: username, weeklyMix: weeklyMix)
        try await scheduleWeeklyReview(settings: settings)

        return ReminderScheduleResult(
            statusText: "Daily practice and weekly review reminders scheduled.",
            permissionText: "macOS notifications allowed."
        )
    }

    func currentPermissionText() async -> String {
        let settings = await notificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "macOS notifications allowed."
        case .denied:
            return "Notifications are off in macOS settings."
        case .notDetermined:
            return "Notifications not requested yet."
        @unknown default:
            return "Notification permission status unknown."
        }
    }

    private func requestAuthorizationIfNeeded() async throws -> Bool {
        let settings = await notificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound])
        @unknown default:
            return false
        }
    }

    private func scheduleDailyPractice(
        settings: SharedGoalSettings,
        username: String,
        weeklyMix: String
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Small step, real progress"
        content.body = "\(username), keep momentum warm with one focused session: \(weeklyMix)."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = settings.reminderHour
        dateComponents.minute = settings.reminderMinute

        let request = UNNotificationRequest(
            identifier: Identifier.dailyPractice,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        )

        try await notificationCenter.add(request)
    }

    private func scheduleWeeklyReview(settings: SharedGoalSettings) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Reset your LeetCode week"
        content.body = "Check your pace, celebrate what moved, and pick the next small win."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = settings.reminderHour
        dateComponents.minute = settings.reminderMinute

        let request = UNNotificationRequest(
            identifier: Identifier.weeklyReview,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        )

        try await notificationCenter.add(request)
    }
}
