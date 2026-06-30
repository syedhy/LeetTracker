import Foundation

struct LeetCodeClient {
    private let endpoint: URL?
    private let session: URLSession

    init(endpoint: URL? = URL(string: "https://leetcode.com/graphql"), session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    func fetchStats(for username: String) async throws -> LeetCodeStats {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedUsername.isEmpty else {
            throw LeetCodeProfileError.invalidUsername
        }

        guard let endpoint else {
            throw LeetCodeProfileError.endpointChanged
        }

        let payload = GraphQLRequest(
            query: """
            query userStats($username: String!) {
              matchedUser(username: $username) {
                username
                submitStats {
                  acSubmissionNum {
                    difficulty
                    count
                  }
                }
                userCalendar {
                  totalActiveDays
                  submissionCalendar
                }
              }
            }
            """,
            variables: Variables(username: normalizedUsername)
        )

        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("LeetTracker macOS (https://github.com/syedhy/leettracker)", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONEncoder().encode(payload)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw map(error)
        } catch {
            throw LeetCodeProfileError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeetCodeProfileError.malformedResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw httpResponse.statusCode == 400
                ? LeetCodeProfileError.malformedResponse
                : LeetCodeProfileError.networkUnavailable
        }

        let decoded: GraphQLResponse

        do {
            decoded = try JSONDecoder().decode(GraphQLResponse.self, from: data)
        } catch {
            throw LeetCodeProfileError.malformedResponse
        }

        guard decoded.errors?.isEmpty != false else {
            throw LeetCodeProfileError.malformedResponse
        }

        guard let matchedUser = decoded.data?.matchedUser else {
            throw LeetCodeProfileError.profileNotFound
        }

        return try stats(from: matchedUser)
    }

    private func stats(from matchedUser: MatchedUser) throws -> LeetCodeStats {
        let rows = matchedUser.submitStats.acSubmissionNum
        let counts = rows.reduce(into: [String: Int]()) { partialResult, row in
            partialResult[row.difficulty.lowercased(), default: 0] += row.count
        }

        let totalSolved = counts["all"] ?? 0
        let easySolved = counts["easy"] ?? 0
        let mediumSolved = counts["medium"] ?? 0
        let hardSolved = counts["hard"] ?? 0

        return LeetCodeStats(
            username: matchedUser.username,
            totalSolved: totalSolved,
            easySolved: easySolved,
            mediumSolved: mediumSolved,
            hardSolved: hardSolved,
            currentStreak: currentStreak(from: matchedUser.userCalendar?.submissionCalendar) ?? 0,
            totalActiveDays: matchedUser.userCalendar?.totalActiveDays,
            lastUpdated: Date()
        )
    }

    private func currentStreak(from submissionCalendar: String?) -> Int? {
        guard
            let submissionCalendar,
            let data = submissionCalendar.data(using: .utf8),
            let acceptedByTimestamp = try? JSONDecoder().decode([String: Int].self, from: data)
        else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let solvedDays = Set(
            acceptedByTimestamp.compactMap { timestamp, acceptedCount -> Date? in
                guard acceptedCount > 0, let seconds = TimeInterval(timestamp) else {
                    return nil
                }

                return calendar.startOfDay(for: Date(timeIntervalSince1970: seconds))
            }
        )

        var cursor = calendar.startOfDay(for: Date())
        
        if !solvedDays.contains(cursor) {
            if let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) {
                cursor = previousDay
            }
        }

        var streak = 0

        while solvedDays.contains(cursor) {
            streak += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }

    private func map(_ error: URLError) -> LeetCodeProfileError {
        switch error.code {
        case .timedOut:
            .timeout
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed:
            .networkUnavailable
        default:
            .networkUnavailable
        }
    }
}

private struct GraphQLRequest: Encodable {
    let query: String
    let variables: Variables
}

private struct Variables: Encodable {
    let username: String
}

private struct GraphQLResponse: Decodable {
    let data: GraphQLData?
    let errors: [GraphQLError]?
}

private struct GraphQLData: Decodable {
    let matchedUser: MatchedUser?
}

private struct MatchedUser: Decodable {
    let username: String
    let submitStats: SubmitStats
    let userCalendar: UserCalendar?
}

private struct SubmitStats: Decodable {
    let acSubmissionNum: [SolvedCount]
}

private struct UserCalendar: Decodable {
    let totalActiveDays: Int?
    let submissionCalendar: String?
}

private struct SolvedCount: Decodable {
    let difficulty: String
    let count: Int
}

private struct GraphQLError: Decodable {
    let message: String?
}
