import XCTest
@testable import LeetTracker

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.mockData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    override func stopLoading() {}
}

final class LeetCodeClientTests: XCTestCase {
    func testInvalidUsernameThrowsError() async {
        let client = LeetCodeClient()
        do {
            _ = try await client.fetchStats(for: "   ")
            XCTFail("Expected invalidUsername error")
        } catch let error as LeetCodeProfileError {
            XCTAssertEqual(error, .invalidUsername)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAPIDecoding() async throws {
        let json = """
        {
          "data": {
            "matchedUser": {
              "username": "testuser",
              "submitStats": {
                "acSubmissionNum": [
                  { "difficulty": "All", "count": 100 },
                  { "difficulty": "Easy", "count": 50 },
                  { "difficulty": "Medium", "count": 40 },
                  { "difficulty": "Hard", "count": 10 }
                ]
              },
              "userCalendar": {
                "totalActiveDays": 200,
                "submissionCalendar": "{\\"1700000000\\": 1}"
              }
            }
          }
        }
        """
        
        MockURLProtocol.mockData = json.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: "https://leetcode.com/graphql")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.mockError = nil
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = LeetCodeClient(session: session)
        let stats = try await client.fetchStats(for: "testuser")
        
        XCTAssertEqual(stats.username, "testuser")
        XCTAssertEqual(stats.totalSolved, 100)
        XCTAssertEqual(stats.easySolved, 50)
        XCTAssertEqual(stats.mediumSolved, 40)
        XCTAssertEqual(stats.hardSolved, 10)
        XCTAssertEqual(stats.totalActiveDays, 200)
    }
}
