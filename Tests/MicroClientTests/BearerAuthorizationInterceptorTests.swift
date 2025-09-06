import Foundation
import Testing

@testable import MicroClient

@Suite("BearerAuthorizationInterceptor Tests")
struct BearerAuthorizationInterceptorTests {

    @Test("It should add Authorization header when token is provided")
    func addsAuthorizationHeaderWithToken() async throws {
        // Given
        let expectedToken = "test-token-123"
        let tokenProvider: @Sendable () async -> String? = { expectedToken }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == "Bearer \(expectedToken)",
            "It should add Bearer token to Authorization header"
        )
    }

    @Test("It should not add Authorization header when token is nil")
    func doesNotAddAuthorizationHeaderWhenTokenIsNil() async throws {
        // Given
        let tokenProvider: @Sendable () async -> String? = { nil }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == nil,
            "It should not add Authorization header when token is nil"
        )
    }

    @Test("It should replace existing Authorization header when token is provided")
    func replacesExistingAuthorizationHeader() async throws {
        // Given
        let newToken = "new-token-456"
        let tokenProvider: @Sendable () async -> String? = { newToken }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("Basic old-auth", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == "Bearer \(newToken)",
            "It should replace existing Authorization header with Bearer token"
        )
    }

    @Test("It should preserve existing Authorization header when token is nil")
    func preservesExistingAuthorizationHeaderWhenTokenIsNil() async throws {
        // Given
        let existingAuthHeader = "Basic existing-auth"
        let tokenProvider: @Sendable () async -> String? = { nil }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue(existingAuthHeader, forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == existingAuthHeader,
            "It should preserve existing Authorization header when token is nil"
        )
    }

    @Test("It should preserve other headers when adding Authorization header")
    func preservesOtherHeaders() async throws {
        // Given
        let token = "preserve-headers-token"
        let tokenProvider: @Sendable () async -> String? = { token }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("custom-value", forHTTPHeaderField: "X-Custom-Header")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.value(forHTTPHeaderField: "Authorization") == "Bearer \(token)",
            "It should add Authorization header"
        )
        #expect(
            request.value(forHTTPHeaderField: "Content-Type") == "application/json",
            "It should preserve Content-Type header"
        )
        #expect(
            request.value(forHTTPHeaderField: "X-Custom-Header") == "custom-value",
            "It should preserve custom headers"
        )
    }

    @Test("It should work with async token provider")
    func worksWithAsyncTokenProvider() async throws {
        // Given
        let expectedToken = "async-token"
        let tokenProvider: @Sendable () async -> String? = {
            try? await Task.sleep(nanoseconds: 1_000_000)
            return expectedToken
        }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == "Bearer \(expectedToken)",
            "It should work with async token providers"
        )
    }

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let token = "url-preservation-token"
        let tokenProvider: @Sendable () async -> String? = { token }

        let interceptor = BearerAuthorizationInterceptor(tokenProvider: tokenProvider)
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "POST"
        request.httpBody = Data("test body".utf8)
        request.timeoutInterval = 30.0

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.url == originalURL,
            "It should preserve the original URL"
        )
        #expect(
            request.httpMethod == "POST",
            "It should preserve the HTTP method"
        )
        #expect(
            request.httpBody == Data("test body".utf8),
            "It should preserve the HTTP body"
        )
        #expect(
            request.timeoutInterval == 30.0,
            "It should preserve the timeout interval"
        )
        #expect(
            request.value(forHTTPHeaderField: "Authorization") == "Bearer \(token)",
            "It should add the Authorization header"
        )
    }
}
