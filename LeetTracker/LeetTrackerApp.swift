import SwiftUI

@main
struct LeetTrackerApp: App {
    init() {
        #if os(macOS)
        BackgroundRefreshRunner.runAndExitIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(iOS)
        .backgroundTask(.appRefresh("com.hyder.LeetTracker.refresh")) {
            _ = await BackgroundRefreshRunner.refreshWidgetData()
        }
        #endif
    }
}
//