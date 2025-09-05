import Testing
import Foundation

@testable import MicroClient

@Suite("TimeoutInterceptor Tests")
struct TimeoutInterceptorTests {

    @Test("It should set timeout interval")
    func setsTimeoutInterval() async throws {
        // Given
        let timeoutInterval: TimeInterval = 30.0
        let interceptor = TimeoutInterceptor(timeout: timeoutInterval)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.timeoutInterval == timeoutInterval,
            "It should set the timeout interval"
        )
    }

    @Test("It should replace existing timeout interval")
    func replacesExistingTimeoutInterval() async throws {
        // Given
        let newTimeoutInterval: TimeInterval = 60.0
        let interceptor = TimeoutInterceptor(timeout: newTimeoutInterval)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.timeoutInterval = 10.0

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.timeoutInterval == newTimeoutInterval,
            "It should replace existing timeout interval"
        )
    }

    @Test("It should handle zero timeout")
    func handlesZeroTimeout() async throws {
        // Given
        let zeroTimeout: TimeInterval = 0.0
        let interceptor = TimeoutInterceptor(timeout: zeroTimeout)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.timeoutInterval == zeroTimeout,
            "It should handle zero timeout"
        )
    }

    @Test("It should handle very large timeout")
    func handlesVeryLargeTimeout() async throws {
        // Given
        let largeTimeout: TimeInterval = 86400.0 // 24 hours
        let interceptor = TimeoutInterceptor(timeout: largeTimeout)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.timeoutInterval == largeTimeout,
            "It should handle very large timeouts"
        )
    }

    @Test("It should handle fractional timeout")
    func handlesFractionalTimeout() async throws {
        // Given
        let fractionalTimeout: TimeInterval = 2.5
        let interceptor = TimeoutInterceptor(timeout: fractionalTimeout)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.timeoutInterval == fractionalTimeout,
            "It should handle fractional timeouts"
        )
    }

    @Test("It should preserve other request properties when setting timeout")
    func preservesOtherRequestProperties() async throws {
        // Given
        let timeoutInterval: TimeInterval = 15.0
        let interceptor = TimeoutInterceptor(timeout: timeoutInterval)
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "DELETE"
        request.httpBody = Data("test body".utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.url == originalURL,
            "It should preserve the original URL"
        )
        #expect(
            request.httpMethod == "DELETE",
            "It should preserve the HTTP method"
        )
        #expect(
            request.httpBody == Data("test body".utf8),
            "It should preserve the HTTP body"
        )
        #expect(
            request.value(forHTTPHeaderField: "Content-Type") == "application/json",
            "It should preserve headers"
        )
        #expect(
            request.timeoutInterval == timeoutInterval,
            "It should set the timeout interval"
        )
    }

    @Test("It should preserve headers when setting timeout")
    func preservesHeaders() async throws {
        // Given
        let timeoutInterval: TimeInterval = 20.0
        let interceptor = TimeoutInterceptor(timeout: timeoutInterval)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
        request.setValue("custom-value", forHTTPHeaderField: "X-Custom-Header")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.timeoutInterval == timeoutInterval,
            "It should set the timeout interval"
        )
        #expect(
            request.value(forHTTPHeaderField: "Authorization") == "Bearer token",
            "It should preserve Authorization header"
        )
        #expect(
            request.value(forHTTPHeaderField: "X-Custom-Header") == "custom-value",
            "It should preserve custom headers"
        )
    }
}
