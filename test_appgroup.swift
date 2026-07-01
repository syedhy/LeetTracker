import Foundation
let group = "group.com.hyder.LeetTracker"
print("Container URL: \(String(describing: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)))")
let defaults = UserDefaults(suiteName: group)
defaults?.set("test", forKey: "testKey")
print("Saved to defaults")
