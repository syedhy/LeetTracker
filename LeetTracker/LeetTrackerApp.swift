import SwiftUI

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if CommandLine.arguments.contains("--background-refresh") {
            // Run completely headless
            NSApp.setActivationPolicy(.accessory)
            
            Task {
                let result = await BackgroundRefreshRunner.refreshWidgetData()
                fputs("[\(Date())] \(result.message)\n", stderr)
                NSApp.terminate(nil)
            }
        }
    }
}
#endif

@main
struct LeetTrackerApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            if !CommandLine.arguments.contains("--background-refresh") {
                ContentView()
            } else {
                // Empty view for background refresh, though accessory policy hides the window.
                Text("Background Refresh Running...")
                    .frame(width: 0, height: 0)
                    .hidden()
            }
        }
        #if os(iOS)
        .backgroundTask(.appRefresh("com.hyder.LeetTracker.refresh")) {
            _ = await BackgroundRefreshRunner.refreshWidgetData()
        }
        #endif
    }
}