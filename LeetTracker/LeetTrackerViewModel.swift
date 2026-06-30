import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class LeetTrackerViewModel: ObservableObject {
    @Published var username = ""
    @Published var goalTargetText = ""
    @Published var weeklyTargetText = ""
    @Published var weeklyEasyTargetText = ""
    @Published var weeklyMediumTargetText = ""
    @Published var weeklyHardTargetText = ""
    @Published var remindersEnabled = false
    @Published var reminderTime = Date()
    @Published private(set) var stats: LeetCodeStats?
    @Published private(set) var statusMessage = "Enter a LeetCode username to prepare tracking."
    @Published private(set) var goalStatusMessage = "Goal settings are ready."
    @Published private(set) var reminderPermissionText = "Notifications not requested yet."
    @Published private(set) var completedPlannerSessionIDs: Set<String> = []
    @Published private(set) var isLoading = false

    private let client: LeetCodeClient
    private let sharedStore: SharedLeetTrackerStore
    private let reminderScheduler: ReminderScheduler
    private let plannerDefaults: UserDefaults
    private var savedGoalSettings = SharedGoalSettings.default
    private var hasSavedGoalSettings = false

    init(
        client: LeetCodeClient = LeetCodeClient(),
        sharedStore: SharedLeetTrackerStore = SharedLeetTrackerStore(),
        reminderScheduler: ReminderScheduler = ReminderScheduler(),
        plannerDefaults: UserDefaults = .standard
    ) {
        self.client = client
        self.sharedStore = sharedStore
        self.reminderScheduler = reminderScheduler
        self.plannerDefaults = plannerDefaults
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var totalSolvedText: String {
        statText(stats?.totalSolved)
    }

    var easySolvedText: String {
        statText(stats?.easySolved)
    }

    var mediumSolvedText: String {
        statText(stats?.mediumSolved)
    }

    var hardSolvedText: String {
        statText(stats?.hardSolved)
    }

    var displayUsername: String {
        if let username = stats?.username, !username.isEmpty {
            return username
        }

        if !trimmedUsername.isEmpty {
            return trimmedUsername
        }

        return "No profile selected"
    }

    var lastUpdatedText: String {
        guard let lastUpdated = stats?.lastUpdated else {
            return "Not synced yet"
        }

        return "Updated \(formatted(lastUpdated))"
    }

    var dashboardSubtitle: String {
        guard let stats else {
            return "Public LeetCode progress dashboard"
        }

        return "\(stats.username) · \(stats.totalSolved) solved"
    }



    var difficultyMixText: String {
        guard let stats, stats.totalSolved > 0 else {
            return "--"
        }

        let mediumHard = stats.mediumSolved + stats.hardSolved
        let percentage = Int((Double(mediumHard) / Double(stats.totalSolved) * 100).rounded())
        return "\(percentage)% M/H"
    }

    var nextMilestoneText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        return "\(nextMilestone(after: totalSolved)) solved"
    }

    var goalTargetDisplayText: String {
        "\(goalTargetValue) solved"
    }

    var focusGoalHeadline: String {
        guard stats != nil else {
            return "Set a target"
        }

        return "Target \(savedGoalSettings.targetSolved)"
    }

    var focusGoalSubtitle: String {
        guard let stats else {
            return "Refresh a profile to start goal tracking."
        }

        return "\(stats.totalSolved) solved now · \(goalRemainingText) remaining"
    }

    var goalRemainingText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "--"
        }

        return "\(max(0, savedGoalSettings.targetSolved - totalSolved))"
    }



    var weeklyPracticeMixText: String {
        let easy = weeklyEasyTargetValue
        let medium = weeklyMediumTargetValue
        let hard = weeklyHardTargetValue

        if hard > 0 {
            return "\(easy) Easy, \(medium) Medium, \(hard) Hard"
        }

        return "\(easy) Easy, \(medium) Medium"
    }

    var plannerSessions: [PlannerSession] {
        let targets = difficultyTargets(from: savedGoalSettings)
        return WeeklyPlannerFactory.makeSessions(
            easy: targets.easy,
            medium: targets.medium,
            hard: targets.hard
        )
    }

    var plannerMixText: String {
        let targets = difficultyTargets(from: savedGoalSettings)
        return difficultyMixText(easy: targets.easy, medium: targets.medium, hard: targets.hard)
    }

    var plannerPaceText: String {
        paceText(for: savedGoalSettings.weeklyTarget)
    }

    var plannerRemindersEnabled: Bool {
        savedGoalSettings.remindersEnabled
    }

    var plannerReminderTimeText: String {
        guard savedGoalSettings.remindersEnabled else {
            return "Off"
        }

        let date = reminderDate(hour: savedGoalSettings.reminderHour, minute: savedGoalSettings.reminderMinute)
        return formattedTime(date)
    }

    var plannerWeeklyReviewText: String {
        savedGoalSettings.remindersEnabled ? "Sundays at \(plannerReminderTimeText)" : "Off"
    }

    var plannerGoalDistanceText: String {
        guard let totalSolved = stats?.totalSolved else {
            return "Refresh profile"
        }

        let remaining = max(0, savedGoalSettings.targetSolved - totalSolved)
        return remaining == 0 ? "Goal reached" : "\(remaining) problems left"
    }

    var plannerWeekTitle: String {
        WeeklyPlannerFactory.weekTitle()
    }

    var plannerCompletedCount: Int {
        plannerSessions.filter { completedPlannerSessionIDs.contains($0.id) }.count
    }

    var plannerProgress: Double {
        guard !plannerSessions.isEmpty else {
            return 0
        }

        return Double(plannerCompletedCount) / Double(plannerSessions.count)
    }

    var plannerNextSessionText: String {
        guard let nextSession = plannerSessions.first(where: { !completedPlannerSessionIDs.contains($0.id) }) else {
            return plannerSessions.isEmpty
                ? "Set weekly difficulty targets in Goals to generate your practice board."
                : "This week's board is complete. Review the goal before planning the next week."
        }

        return "Next: \(nextSession.dayText) · \(nextSession.difficulty.sessionTitle) · \(nextSession.difficulty.rawValue)"
    }



    var cacheStatusText: String {
        guard let lastUpdated = stats?.lastUpdated else {
            return "Empty"
        }

        return formatted(lastUpdated)
    }

    var refreshCadenceText: String {
        LeetTrackerWidgetConfiguration.refreshIntervalDescription
    }

    var statsSnapshot: LeetCodeStats? {
        stats
    }

    var currentSolvedValue: Int? {
        stats?.totalSolved
    }





    var goalProgress: Double {
        guard let totalSolved = stats?.totalSolved else { return 0 }
        guard savedGoalSettings.targetSolved > 0 else { return 0 }
        return min(1, Double(totalSolved) / Double(savedGoalSettings.targetSolved))
    }



    var reminderTimeText: String {
        formattedTime(reminderTime)
    }

    var weeklyReviewReminderText: String {
        remindersEnabled ? "Sundays at \(reminderTimeText)" : "Off"
    }

    func loadSavedState() {
        let snapshot = sharedStore.snapshot
        hasSavedGoalSettings = snapshot.hasGoalSettings
        applyGoalSettings(
            snapshot.hasGoalSettings ? snapshot.goalSettings : suggestedGoalSettings(currentTotal: snapshot.cachedStats?.totalSolved),
            status: snapshot.hasGoalSettings ? "Goal loaded." : "Suggested a starting goal."
        )
        syncReminderPermissionStatus()
        loadPlannerCompletion()

        if let savedUsername = snapshot.username {
            username = savedUsername
            statusMessage = "Ready to track \(savedUsername)."
        }

        if let cachedStats = snapshot.cachedStats {
            if username.isEmpty {
                username = cachedStats.username
            }

            stats = LeetCodeStats(cachedStats: cachedStats)
            statusMessage = "Loaded \(cachedStats.username). Updated \(formatted(cachedStats.lastUpdated))."
        }
    }

    func saveGoalSettings() {
        let currentTotal = stats?.totalSolved ?? 0
        let target = max(currentTotal, parsePositiveInt(goalTargetText, fallback: savedGoalSettings.targetSolved))
        
        let easy = max(0, parsePositiveInt(weeklyEasyTargetText, fallback: savedGoalSettings.weeklyEasyTarget ?? 0))
        let medium = max(0, parsePositiveInt(weeklyMediumTargetText, fallback: savedGoalSettings.weeklyMediumTarget ?? 0))
        let hard = max(0, parsePositiveInt(weeklyHardTargetText, fallback: savedGoalSettings.weeklyHardTarget ?? 0))
        
        let weeklyTarget = max(1, easy + medium + hard)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)

        let settings = SharedGoalSettings(
            targetSolved: target,
            weeklyTarget: weeklyTarget,
            weeklyEasyTarget: easy,
            weeklyMediumTarget: medium,
            weeklyHardTarget: hard,
            remindersEnabled: remindersEnabled,
            reminderHour: components.hour ?? savedGoalSettings.reminderHour,
            reminderMinute: components.minute ?? savedGoalSettings.reminderMinute,
            updatedAt: Date()
        )

        sharedStore.saveGoalSettings(settings)
        hasSavedGoalSettings = true
        let statusPrefix = "Saved \(weeklyTarget)/week toward \(target) solved."
        applyGoalSettings(settings, status: statusPrefix)
        updateReminderSchedule(settings, statusPrefix: statusPrefix)
        removePlannerCompletionsNotInCurrentPlan()
    }

    func togglePlannerSession(_ id: String) {
        if completedPlannerSessionIDs.contains(id) {
            completedPlannerSessionIDs.remove(id)
        } else {
            completedPlannerSessionIDs.insert(id)
        }

        savePlannerCompletion()
    }

    func resetPlannerWeek() {
        completedPlannerSessionIDs.removeAll()
        savePlannerCompletion()
    }

    func refreshStats() async -> Bool {
        let normalizedUsername = trimmedUsername

        guard !normalizedUsername.isEmpty else {
            statusMessage = LeetCodeProfileError.invalidUsername.localizedDescription
            return false
        }

        isLoading = true
        statusMessage = "Fetching stats for \(normalizedUsername)"

        defer {
            isLoading = false
        }

        do {
            let freshStats = try await client.fetchStats(for: normalizedUsername)
            username = freshStats.username
            stats = freshStats

            if !hasSavedGoalSettings {
                applyGoalSettings(
                    suggestedGoalSettings(currentTotal: freshStats.totalSolved),
                    status: "Suggested a starting goal."
                )
            }

            sharedStore.saveUsername(freshStats.username)
            sharedStore.saveCachedStats(freshStats.cachedStats)
            statusMessage = "Updated \(freshStats.username). Last checked \(formatted(freshStats.lastUpdated))."
            return true
        } catch let error as LeetCodeProfileError {
            showCachedStatsAfterFailure(error)
            return false
        } catch {
            showCachedStatsAfterFailure(.networkUnavailable)
            return false
        }
    }

    func markWidgetReloadRequested(at date: Date) {
        guard let stats else {
            return
        }

        sharedStore.synchronize()
        statusMessage = "Updated \(stats.username). Widget reload requested at \(formatted(date)). Saved \(stats.totalSolved) solved."
    }

    private func showCachedStatsAfterFailure(_ error: LeetCodeProfileError) {
        if let cachedStats = sharedStore.cachedStats {
            stats = LeetCodeStats(cachedStats: cachedStats)

            if trimmedUsername.isEmpty {
                username = cachedStats.username
            }

            statusMessage = "\(error.localizedDescription) Showing saved stats from \(formatted(cachedStats.lastUpdated))."
        } else {
            statusMessage = "\(error.localizedDescription) No saved stats yet."
        }
    }

    private func statText(_ value: Int?) -> String {
        guard let value else {
            return "--"
        }

        return "\(value)"
    }

    private func nextMilestone(after totalSolved: Int) -> Int {
        ((totalSolved / 10) + 1) * 10
    }

    private func suggestedGoalSettings(currentTotal: Int?) -> SharedGoalSettings {
        let target = currentTotal.map(nextMilestone) ?? SharedGoalSettings.default.targetSolved

        return SharedGoalSettings(
            targetSolved: target,
            weeklyTarget: SharedGoalSettings.default.weeklyTarget,
            weeklyEasyTarget: SharedGoalSettings.default.weeklyEasyTarget,
            weeklyMediumTarget: SharedGoalSettings.default.weeklyMediumTarget,
            weeklyHardTarget: SharedGoalSettings.default.weeklyHardTarget,
            remindersEnabled: SharedGoalSettings.default.remindersEnabled,
            reminderHour: SharedGoalSettings.default.reminderHour,
            reminderMinute: SharedGoalSettings.default.reminderMinute,
            updatedAt: Date()
        )
    }

    private var goalTargetValue: Int {
        max(1, parsePositiveInt(goalTargetText, fallback: savedGoalSettings.targetSolved))
    }

    private var weeklyTargetValue: Int {
        max(1, parsePositiveInt(weeklyTargetText, fallback: savedGoalSettings.weeklyTarget))
    }

    private var weeklyEasyTargetValue: Int {
        max(0, parsePositiveInt(weeklyEasyTargetText, fallback: savedGoalSettings.weeklyEasyTarget ?? suggestedDifficultyTargets(for: weeklyTargetValue).easy))
    }

    private var weeklyMediumTargetValue: Int {
        max(0, parsePositiveInt(weeklyMediumTargetText, fallback: savedGoalSettings.weeklyMediumTarget ?? suggestedDifficultyTargets(for: weeklyTargetValue).medium))
    }

    private var weeklyHardTargetValue: Int {
        max(0, parsePositiveInt(weeklyHardTargetText, fallback: savedGoalSettings.weeklyHardTarget ?? suggestedDifficultyTargets(for: weeklyTargetValue).hard))
    }

    private func applyGoalSettings(_ settings: SharedGoalSettings, status: String) {
        savedGoalSettings = settings
        goalTargetText = "\(settings.targetSolved)"
        weeklyTargetText = "\(settings.weeklyTarget)"
        let difficultyTargets = difficultyTargets(from: settings)
        weeklyEasyTargetText = "\(difficultyTargets.easy)"
        weeklyMediumTargetText = "\(difficultyTargets.medium)"
        weeklyHardTargetText = "\(difficultyTargets.hard)"
        remindersEnabled = settings.remindersEnabled
        reminderTime = reminderDate(hour: settings.reminderHour, minute: settings.reminderMinute)
        goalStatusMessage = status
    }

    private func syncReminderPermissionStatus() {
        Task {
            reminderPermissionText = await reminderScheduler.currentPermissionText()
        }
    }

    private func updateReminderSchedule(_ settings: SharedGoalSettings, statusPrefix: String) {
        Task {
            do {
                let result = try await reminderScheduler.apply(
                    settings: settings,
                    username: displayUsername,
                    weeklyMix: weeklyPracticeMixText
                )
                goalStatusMessage = "\(statusPrefix) \(result.statusText)"
                reminderPermissionText = result.permissionText
            } catch {
                goalStatusMessage = "\(statusPrefix) \(error.localizedDescription)"
                reminderPermissionText = error.localizedDescription
            }
        }
    }

    private func parsePositiveInt(_ text: String, fallback: Int) -> Int {
        let digits = text.filter(\.isNumber)
        let truncated = String(digits.prefix(6))
        return Int(truncated) ?? fallback
    }

    private func normalizedDifficultyTargets(fallbackWeeklyTarget: Int) -> (easy: Int, medium: Int, hard: Int) {
        let fallback = suggestedDifficultyTargets(for: fallbackWeeklyTarget)
        let easy = max(0, parsePositiveInt(weeklyEasyTargetText, fallback: savedGoalSettings.weeklyEasyTarget ?? fallback.easy))
        let medium = max(0, parsePositiveInt(weeklyMediumTargetText, fallback: savedGoalSettings.weeklyMediumTarget ?? fallback.medium))
        let hard = max(0, parsePositiveInt(weeklyHardTargetText, fallback: savedGoalSettings.weeklyHardTarget ?? fallback.hard))

        guard easy + medium + hard > 0 else {
            return fallback
        }

        return (easy, medium, hard)
    }

    private func difficultyTargets(from settings: SharedGoalSettings) -> (easy: Int, medium: Int, hard: Int) {
        let fallback = suggestedDifficultyTargets(for: settings.weeklyTarget)
        return (
            max(0, settings.weeklyEasyTarget ?? fallback.easy),
            max(0, settings.weeklyMediumTarget ?? fallback.medium),
            max(0, settings.weeklyHardTarget ?? fallback.hard)
        )
    }

    private func suggestedDifficultyTargets(for weeklyTarget: Int) -> (easy: Int, medium: Int, hard: Int) {
        let easy = max(1, Int((Double(weeklyTarget) * 0.20).rounded(.down)))
        let hard = weeklyTarget >= 5 ? 1 : 0
        let medium = max(0, weeklyTarget - easy - hard)
        return (easy, medium, hard)
    }

    private func difficultyMixText(easy: Int, medium: Int, hard: Int) -> String {
        if hard > 0 {
            return "\(easy) Easy, \(medium) Medium, \(hard) Hard"
        }

        return "\(easy) Easy, \(medium) Medium"
    }

    private func paceText(for weeklyTarget: Int) -> String {
        if weeklyTarget >= 7 {
            let perDay = Double(weeklyTarget) / 7
            return String(format: "%.1f per day", perDay)
        }

        let spacing = Int(ceil(7.0 / Double(max(1, weeklyTarget))))
        return spacing <= 1 ? "1 per day" : "1 every \(spacing) days"
    }

    private func reminderDate(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: min(23, max(0, hour)),
            minute: min(59, max(0, minute)),
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private func formatted(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private var plannerCompletionKey: String {
        "com.hyder.LeetTracker.planner.completed.\(WeeklyPlannerFactory.weekIdentifier())"
    }

    private func loadPlannerCompletion() {
        let savedIDs = plannerDefaults.stringArray(forKey: plannerCompletionKey) ?? []
        completedPlannerSessionIDs = Set(savedIDs)
        removePlannerCompletionsNotInCurrentPlan()
    }

    private func savePlannerCompletion() {
        plannerDefaults.set(Array(completedPlannerSessionIDs).sorted(), forKey: plannerCompletionKey)
    }

    private func removePlannerCompletionsNotInCurrentPlan() {
        let validIDs = Set(plannerSessions.map(\.id))
        let filteredIDs = completedPlannerSessionIDs.intersection(validIDs)

        guard filteredIDs != completedPlannerSessionIDs else {
            return
        }

        completedPlannerSessionIDs = filteredIDs
        savePlannerCompletion()
    }

    func refreshStatsAndReloadWidgets() {
        Task {
            if await refreshStats() {
                let requestedAt = Date()
                WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.kind)
                WidgetCenter.shared.reloadTimelines(ofKind: LeetTrackerWidgetConfiguration.streakKind)
                WidgetCenter.shared.reloadAllTimelines()
                markWidgetReloadRequested(at: requestedAt)
            }
        }
    }
}
