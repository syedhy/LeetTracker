import Foundation

struct LeetCodeClient {
    private let endpoint = URL(string: "https://leetcode.com/graphql")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchStats(for username: String) async throws -> LeetCodeStats {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedUsername.isEmpty else {
            throw LeetCodeProfileError.invalidUsername
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
              }
            }
            """,
            variables: Variables(username: normalizedUsername)
        )

        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("LeetTracker macOS", forHTTPHeaderField: "User-Agent")
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
        let counts = Dictionary(uniqueKeysWithValues: rows.map { row in
            (row.difficulty.lowercased(), row.count)
        })

        guard
            let totalSolved = counts["all"],
            let easySolved = counts["easy"],
            let mediumSolved = counts["medium"],
            let hardSolved = counts["hard"]
        else {
            throw LeetCodeProfileError.endpointChanged
        }

        return LeetCodeStats(
            username: matchedUser.username,
            totalSolved: totalSolved,
            easySolved: easySolved,
            mediumSolved: mediumSolved,
            hardSolved: hardSolved,
            lastUpdated: Date()
        )
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
}

private struct SubmitStats: Decodable {
    let acSubmissionNum: [SolvedCount]
}

private struct SolvedCount: Decodable {
    let difficulty: String
    let count: Int
}

private struct GraphQLError: Decodable {
    let message: String?
}
