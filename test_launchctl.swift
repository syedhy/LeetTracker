import Foundation
let uid = getuid()
let plist = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.hyder.test.launchctl</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/echo</string>
		<string>hello</string>
	</array>
</dict>
</plist>
"""
let url = URL(fileURLWithPath: NSHomeDirectory() + "/Library/LaunchAgents/com.hyder.test.launchctl.plist")
try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
try! plist.write(to: url, atomically: true, encoding: .utf8)
let p = Process()
p.executableURL = URL(fileURLWithPath: "/bin/launchctl")
p.arguments = ["bootstrap", "gui/\(uid)", url.path]
let out = Pipe(), err = Pipe()
p.standardOutput = out
p.standardError = err
try! p.run()
p.waitUntilExit()
print("Exit: \(p.terminationStatus)")
print("Err: \(String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!)")
