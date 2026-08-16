// MIT License
//
// Copyright (c) 2026 Otávio C.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import Testing
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
    func retryOnFailure() async {
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
    func notRetryWhenStrategyIsNone() async {
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
    func requestSpecificRetryOverridesConfiguration() async {
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
            "It should make 3 requests"
        )
    }
}
