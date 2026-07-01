import XCTest
@testable import LeetTracker

@MainActor
final class LeetTrackerViewModelTests: XCTestCase {
    func testGoalParsing() {
        let viewModel = LeetTrackerViewModel()
        viewModel.goalTargetText = "150"
        viewModel.weeklyTargetText = "7"
        viewModel.weeklyEasyTargetText = "3"
        viewModel.weeklyMediumTargetText = "3"
        viewModel.weeklyHardTargetText = "1"
        viewModel.saveGoalSettings()
        
        XCTAssertTrue(viewModel.goalStatusMessage.contains("Saved 7/week toward 150 solved"))
    }
    
    func testCachedFallbackBehavior() {
        UserDefaults(suiteName: SharedLeetTrackerStore.appGroupIdentifier)?.removePersistentDomain(forName: SharedLeetTrackerStore.appGroupIdentifier)
        let viewModel = LeetTrackerViewModel()
        let store = SharedLeetTrackerStore()
        
        let cachedStats = CachedLeetCodeStats(username: "fallbackUser", totalSolved: 50, easySolved: 20, mediumSolved: 20, hardSolved: 10, currentStreak: 5, totalActiveDays: 100, lastUpdated: Date())
        store.saveCachedStats(cachedStats)
        
        viewModel.loadSavedState()
        
        XCTAssertEqual(viewModel.username, "fallbackUser")
        XCTAssertEqual(viewModel.stats?.totalSolved, 50)
    }
}
