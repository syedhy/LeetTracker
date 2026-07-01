import Foundation

enum BackgroundRefreshManager {
    static let agentIdentifier = "com.hyder.LeetTracker.refresh"
    
    static var launchAgentURL: URL {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let launchAgentsURL = libraryURL.appendingPathComponent("LaunchAgents")
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: launchAgentsURL, withIntermediateDirectories: true)
        
        return launchAgentsURL.appendingPathComponent("\(agentIdentifier).plist")
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
            "StandardErrorPath": "/tmp/LeetTracker_BackgroundRefresh_err.log",
            "StandardOutPath": "/tmp/LeetTracker_BackgroundRefresh_out.log"
        ]
        
        // Save plist
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: launchAgentURL)
        
        // Load the agent using launchctl
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["load", launchAgentURL.path]
        try process.run()
        process.waitUntilExit()
    }
    
    static func uninstall() throws {
        if isInstalled {
            // Unload the agent
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
            process.arguments = ["unload", launchAgentURL.path]
            try? process.run()
            process.waitUntilExit()
            
            // Remove the file
            try FileManager.default.removeItem(at: launchAgentURL)
        }
    }
}
