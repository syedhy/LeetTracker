import XCTest
@testable import LeetTracker

final class BackgroundRefreshManagerTests: XCTestCase {
    func testIsInstalledChecksPath() {
        let url = BackgroundRefreshManager.launchAgentURL
        XCTAssertTrue(url.path.contains("com.hyder.LeetTracker.background-refresh.plist"))
    }
}
