import SwiftUI

@main
struct LeetTrackerApp: App {
    init() {
        BackgroundRefreshRunner.runAndExitIfRequested()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
