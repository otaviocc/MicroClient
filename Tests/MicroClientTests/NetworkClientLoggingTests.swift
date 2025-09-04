
import Testing
import Foundation

@testable import MicroClient

@Suite("NetworkClient Logging Tests")
struct NetworkClientLoggingTests {

    @Test("It should log request and response on success")
    func logRequestAndResponseOnSuccess() async throws {
        let mockLogger = LoggerMock()
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            logger: mockLogger,
            logLevel: .debug
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/test"))
        let responseData = try JSONEncoder().encode(TestModelMother.makeSuccessfulResponseModel())
        mockSession.stubDataToReturn(
            data: responseData,
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let request = NetworkRequest<VoidRequest, TestResponseModel>(
            path: "/test",
            method: .get
        )

        _ = try await client.run(request)

        let messages = mockLogger.loggedMessages

        #expect(
            messages.count == 5,
            "It should log 5 messages"
        )
        #expect(
            messages.contains(where: { $0.level == .info && $0.message.contains("Request:") }),
            "It should log request info"
        )
        #expect(
            messages.contains(where: { $0.level == .debug && $0.message.contains("Headers:") }),
            "It should log request headers"
        )
        #expect(
            messages.contains(where: { $0.level == .info && $0.message.contains("Response:") }),
            "It should log response info"
        )
        #expect(
            messages.contains(where: { $0.level == .debug && $0.message.contains("Response headers:") }),
            "It should log response headers"
        )
        #expect(
            messages.contains(where: { $0.level == .debug && $0.message.contains("Response data:") }),
            "It should log response data"
        )
    }

    @Test("It should log error on failure")
    func logErrorOnFailure() async throws {
        let mockLogger = LoggerMock()
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            logger: mockLogger,
            logLevel: .error
        )

        mockSession.stubDataToThrow(error: URLError(.badURL))

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/fail",
            method: .get
        )

        _ = try? await client.run(request)

        #expect(
            mockLogger.loggedMessages.contains(where: { $0.level == .error && $0.message.contains("Transport error:") }),
            "It should log a transport error"
        )
    }

    @Test("It should log retries")
    func logRetries() async throws {
        let mockLogger = LoggerMock()
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: .retry(count: 2),
            logger: mockLogger,
            logLevel: .warning
        )

        mockSession.stubDataToThrow(error: URLError(.notConnectedToInternet))

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/retry",
            method: .get
        )

        _ = try? await client.run(request)

        #expect(
            mockLogger.loggedMessages.count(where: { $0.level == .warning && $0.message.contains("Retrying") }) == 2,
            "It should log 2 retry attempts"
        )
    }

    @Test("It should respect log level")
    func respectLogLevel() async throws {
        let mockLogger = LoggerMock()
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            logger: mockLogger,
            logLevel: .info
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/loglevel"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/loglevel",
            method: .get
        )

        _ = try await client.run(request)

        #expect(
            !mockLogger.loggedMessages.contains(where: { $0.level == .debug }),
            "It should not log debug messages"
        )
    }
}

// MARK: - Private

private extension Array {
    func count(where predicate: (Element) -> Bool) -> Int {
        self.reduce(0) { count, element in
            count + (predicate(element) ? 1 : 0)
        }
    }
}
