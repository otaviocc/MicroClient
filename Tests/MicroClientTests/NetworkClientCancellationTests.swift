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
import Testing
@testable import MicroClient

@Suite("NetworkClient Cancellation Tests")
struct NetworkClientCancellationTests {

    @Test("It should throw CancellationError when task is cancelled before request")
    func throwCancellationErrorWhenTaskIsCancelledBeforeRequest() async throws {
        // Given
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/test"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL
            )
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        // When
        let task = Task {
            try await client.run(request)
        }

        task.cancel()

        // Then
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }

    @Test("It should cancel ongoing request when task is cancelled mid-flight")
    func cancelOngoingRequestWhenTaskIsCancelledMidFlight() async throws {
        // Given
        let mockSession = NetworkClientMother.makeMockSession()
        mockSession.delay = 0.1

        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/test"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL
            )
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        // When
        let task = Task {
            try await client.run(request)
        }

        try await Task.sleep(nanoseconds: 10_000_000)
        task.cancel()

        // Then
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }

    @Test("It should cancel request during retry attempts")
    func cancelRequestDuringRetryAttempts() async throws {
        // Given
        let mockSession = NetworkClientMother.makeMockSession()
        mockSession.delay = 0.05
        mockSession.stubDataToThrow(
            error: URLError(.networkConnectionLost)
        )

        let retryStrategy = RetryStrategy.retry(count: 5)
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession,
            retryStrategy: retryStrategy
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        // When
        let task = Task {
            try await client.run(request)
        }

        try await Task.sleep(nanoseconds: 60_000_000)
        task.cancel()

        // Then
        await #expect(throws: CancellationError.self) {
            try await task.value
        }

        #expect(
            mockSession.requestCount < retryStrategy.count + 1,
            "It should not complete all retry attempts"
        )
    }

    @Test("It should complete successfully if not cancelled")
    func completeSuccessfullyIfNotCancelled() async throws {
        // Given
        let mockSession = NetworkClientMother.makeMockSession()
        mockSession.delay = 0.01

        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/test"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL
            )
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        // When
        let response = try await client.run(request)

        // Then
        #expect(
            type(of: response.value) == VoidResponse.self,
            "It should return VoidResponse"
        )

        #expect(
            mockSession.requestCount == 1,
            "It should make exactly one request"
        )
    }
}
