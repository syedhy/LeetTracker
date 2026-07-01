import Foundation

let uid = getuid()
let pw = getpwuid(uid)
let realHome = String(cString: pw!.pointee.pw_dir)
let storePath = realHome + "/Library/Application Support/LeetTrackerShared/LeetTrackerSharedStore.json"

do {
    let data = try String(contentsOfFile: storePath)
    print("Widget read successfully: \(data.count) bytes")
} catch {
    print("Widget read failed: \(error)")
}
