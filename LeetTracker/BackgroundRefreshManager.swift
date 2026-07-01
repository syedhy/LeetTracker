import Foundation
import Darwin

enum BackgroundRefreshManager {
    static let agentIdentifier = "com.hyder.LeetTracker.background-refresh"
    
    static var launchAgentURL: URL {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let launchAgentsURL = libraryURL.appendingPathComponent("LaunchAgents")
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: launchAgentsURL, withIntermediateDirectories: true)
        
        return launchAgentsURL.appendingPathComponent("\(agentIdentifier).plist")
    }
    
    static var logURL: URL {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let logsDir = libraryURL.appendingPathComponent("Logs").appendingPathComponent("LeetTracker")
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        return logsDir.appendingPathComponent("background-refresh.log")
    }
    
    static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: launchAgentURL.path)
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
        
        // Bootstrap the agent using launchctl
        let uid = getuid()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["bootstrap", "gui/\(uid)", launchAgentURL.path]
        try process.run()
        process.waitUntilExit()
        
        // kickstart to ensure it runs now
        let ksProcess = Process()
        ksProcess.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        ksProcess.arguments = ["kickstart", "-p", "gui/\(uid)/\(agentIdentifier)"]
        try? ksProcess.run()
        ksProcess.waitUntilExit()
    }
    
    static func uninstall(removeFile: Bool = true) throws {
        let uid = getuid()
        
        // Bootout the agent
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        // Note: bootout requires the exact service target if we aren't specifying a plist path.
        // It's safer to use the service target: gui/UID/label or just pass the plist path
        process.arguments = ["bootout", "gui/\(uid)/\(agentIdentifier)"]
        try? process.run()
        process.waitUntilExit()
        
        if removeFile && isInstalled {
            // Remove the file
            try? FileManager.default.removeItem(at: launchAgentURL)
        }
    }
}
