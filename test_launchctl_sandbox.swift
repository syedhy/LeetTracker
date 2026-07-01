import Foundation
let uid = getuid()
let pw = getpwuid(uid)
let realHome = String(cString: pw!.pointee.pw_dir)
let plistPath = realHome + "/Library/LaunchAgents/com.hyder.LeetTracker.background-refresh.plist"

let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
process.arguments = ["bootstrap", "gui/\(uid)", plistPath]
let errPipe = Pipe()
process.standardError = errPipe
try! process.run()
process.waitUntilExit()
let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
print("Exit: \(process.terminationStatus)")
print("Err: \(String(data: errData, encoding: .utf8)!)")
