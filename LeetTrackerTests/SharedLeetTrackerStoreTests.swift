import XCTest
@testable import LeetTracker

final class SharedLeetTrackerStoreTests: XCTestCase {
    var store: SharedLeetTrackerStore!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: SharedLeetTrackerStore.appGroupIdentifier)
        userDefaults?.removePersistentDomain(forName: SharedLeetTrackerStore.appGroupIdentifier)
        store = SharedLeetTrackerStore()
    }
    
    func testSaveAndLoadUsername() {
        let testUsername = "test_user_\(UUID().uuidString)"
        store.saveUsername(testUsername)
        XCTAssertEqual(store.username, testUsername)
        
        let snapshot = store.snapshot
        XCTAssertEqual(snapshot.username, testUsername)
    }
    
    func testSaveAndLoadGoalSettings() {
        let settings = SharedGoalSettings(targetSolved: 100, weeklyTarget: 10, weeklyEasyTarget: 5, weeklyMediumTarget: 3, weeklyHardTarget: 2, remindersEnabled: true, reminderHour: 8, reminderMinute: 30, updatedAt: Date())
        store.saveGoalSettings(settings)
        let loaded = store.goalSettings
        XCTAssertEqual(loaded.targetSolved, 100)
        XCTAssertEqual(loaded.weeklyTarget, 10)
        XCTAssertEqual(loaded.weeklyEasyTarget, 5)
    }
}
