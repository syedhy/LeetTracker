import SwiftUI
import Foundation

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Normal app launch setup (if any)
    }
}
#endif

struct LeetTrackerApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(iOS)
        .backgroundTask(.appRefresh("com.hyder.LeetTracker.background-refresh")) {
            _ = await BackgroundRefreshRunner.refreshWidgetData()
        }
        #endif
    }
}

@main
enum AppMain {
    static func main() {
        if CommandLine.arguments.contains("--background-refresh") {
            #if os(macOS)
            // Run completely headless without initializing NSApplication or WindowGroup
            Task {
                let result = await BackgroundRefreshRunner.refreshWidgetData()
                fputs("[\(Date())] \(result.message)\n", stderr)
                exit(result.exitCode)
            }
            dispatchMain()
            #endif
        } else {
            // Launch the normal SwiftUI app UI
            LeetTrackerApp.main()
        }
    }
}