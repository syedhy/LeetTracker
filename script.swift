import Foundation
import Darwin

enum BackgroundRefreshManager {
    static let agentIdentifier = "com.hyder.LeetTracker.background-refresh"
    
    static var realHomeDirectory: String {
        if let pw = getpwuid(getuid()), let dir = pw.pointee.pw_dir {
            return String(cString: dir)
        }
        return NSHomeDirectory()
    }
    
    static var launchAgentURL: URL {
        let launchAgentsURL = URL(fileURLWithPath: realHomeDirectory + "/Library/LaunchAgents")
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: launchAgentsURL, withIntermediateDirectories: true)
        
        return launchAgentsURL.appendingPathComponent("\(agentIdentifier).plist")
    }
    
    static var logURL: URL {
        let logsDir = URL(fileURLWithPath: realHomeDirectory + "/Library/Logs/LeetTracker")
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        return logsDir.appendingPathComponent("background-refresh.log")
    }
    
    static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: launchAgentURL.path)
    }

    static var isLoaded: Bool {
        let uid = getuid()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["print", "gui/\(uid)/\(agentIdentifier)"]
        
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private static func runLaunchctl(_ arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments
        
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
            let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            
            let errString = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let outString = String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let errorMsg = errString.isEmpty ? outString : errString
            
            if let logData = "[\(Date())] Launchctl error (status \(process.terminationStatus)): \(errorMsg)\n".data(using: .utf8) {
                if let handle = try? FileHandle(forWritingTo: logURL) {
                    handle.seekToEndOfFile()
                    handle.write(logData)
                    handle.closeFile()
                } else {
                    try? logData.write(to: logURL)
                }
            }
            
            throw NSError(domain: "BackgroundRefresh", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Background Refresh could not be enabled. Open Diagnostics for details."])
        }
    }
    
    static func install() throws {
        guard let executablePath = Bundle.main.executableURL?.path else {
            throw NSError(domain: "BackgroundRefresh", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find app executable path."])
        }
        
        let plist: [String: Any] = [
            "Label": agentIdentifier,
            "ProgramArguments": [
                executablePath,
                "--background-refresh"
            ],
            "StartInterval": 7200, // 2 hours
            "RunAtLoad": true,
            "StandardErrorPath": logURL.path,
            "StandardOutPath": logURL.path
        ]
        
        // Save plist
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: launchAgentURL)
        
        // Unload first just in case
        try? uninstall(removeFile: false)
        
        let uid = getuid()
        do {
            try runLaunchctl(["bootstrap", "gui/\(uid)", launchAgentURL.path])
            try runLaunchctl(["kickstart", "-p", "gui/\(uid)/\(agentIdentifier)"])
        } catch {
            // If bootstrap fails, delete the plist so it doesn't appear as installed
            try? FileManager.default.removeItem(at: launchAgentURL)
            throw error
        }
    }
    
    static func uninstall(removeFile: Bool = true) throws {
        let uid = getuid()
        
        do {
            try runLaunchctl(["bootout", "gui/\(uid)/\(agentIdentifier)"])
        } catch {
            // Ignore bootout errors, such as "No such process"
        }
        
        if removeFile && isInstalled {
            // Remove the file
            try? FileManager.default.removeItem(at: launchAgentURL)
        }
    }
}

print("Installing...")
try! BackgroundRefreshManager.install()
print("Installed!")
print("Uninstalling...")
try! BackgroundRefreshManager.uninstall()
print("Uninstalled!")
