import Foundation
let p = Process()
p.executableURL = URL(fileURLWithPath: "/bin/launchctl")
p.arguments = ["print", "gui/\(getuid())"]
try! p.run()
p.waitUntilExit()
print("Done")
