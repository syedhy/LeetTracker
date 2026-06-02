import Foundation

enum LeetCodeProfileError: Error, Equatable {
    case invalidUsername
    case profileNotFound
    case networkUnavailable
    case timeout
    case malformedResponse
    case endpointChanged
}

extension LeetCodeProfileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidUsername:
            "Enter a LeetCode username before saving."
        case .profileNotFound:
            "That username was not found on LeetCode."
        case .networkUnavailable:
            "Could not reach LeetCode. Check the network and try again."
        case .timeout:
            "LeetCode took too long to respond. Try again."
        case .malformedResponse:
            "LeetCode returned an unexpected response."
        case .endpointChanged:
            "LeetCode changed the stats response. The parser needs an update."
        }
    }
}
