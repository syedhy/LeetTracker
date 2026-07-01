import Foundation

let path = NSHomeDirectory() + "/Library/Application Support/LeetTrackerShared"
try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
let file = path + "/test.txt"

do {
    try "hello".write(toFile: file, atomically: true, encoding: .utf8)
    print("Wrote successfully to \(file)")
    let read = try String(contentsOfFile: file)
    print("Read successfully: \(read)")
} catch {
    print("Failed: \(error)")
}
