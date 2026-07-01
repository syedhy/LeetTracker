import Foundation
print("NSHomeDirectory(): \(NSHomeDirectory())")
let pw = getpwuid(getuid())
print("pw_dir: \(String(cString: pw!.pointee.pw_dir))")
