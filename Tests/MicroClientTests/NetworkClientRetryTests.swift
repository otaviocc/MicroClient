import Testing
import Foundation

@testable import MicroClient

@Suite("NetworkClient Retry Tests")
struct NetworkClientRetryTests {

    @Test("It should not retry on a successful request")
    func notRetryOnSuccessfulRequest() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: .retry(count: 3)
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/ping"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/ping",
            method: .get
        )

        _ = try await client.run(request)

        #expect(
            mockSession.requestCount == 1,
            "It should make only one request"
        )
    }

    @Test("It should retry on failure up to the specified count")
    func retryOnFailure() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: .retry(count: 3)
        )

        mockSession.stubDataToThrow(error: URLError(.notConnectedToInternet))

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/failure",
            method: .get
        )

        _ = try? await client.run(request)

        #expect(
            mockSession.requestCount == 4,
            "It should make one initial and 3 retry requests"
        )
    }

    @Test("It should not retry when strategy is .none")
    func notRetryWhenStrategyIsNone() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: .none
        )

        mockSession.stubDataToThrow(error: URLError(.notConnectedToInternet))

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/no-retry",
            method: .get
        )

        _ = try? await client.run(request)

        #expect(
            mockSession.requestCount == 1,
            "It should make only one request"
        )
    }

    @Test("Request-specific retry strategy should override configuration")
    func requestSpecificRetryOverridesConfiguration() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: .retry(count: 1)
        )

        mockSession.stubDataToThrow(error: URLError(.notConnectedToInternet))

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/override",
            method: .get,
            retryStrategy: .retry(count: 5)
        )

        _ = try? await client.run(request)

        #expect(
            mockSession.requestCount == 6,
            "It should make one initial and 5 retry requests"
        )
    }

    @Test("It should eventually succeed after a few retries")
    func eventuallySucceedAfterRetries() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: .retry(count: 5)
        )

        mockSession.succeedAfter = 2
        mockSession.stubDataToThrow(error: URLError(.notConnectedToInternet))

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/flaky",
            method: .get
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/flaky"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let response = try await client.run(request)

        #expect(
            (response.response as? HTTPURLResponse)?.statusCode == 200,
            "It should return a successful response"
        )
        #expect(
            mockSession.requestCount == 3,
            "It should have made 3 requests"
        )
    }
}
