import Foundation
import Testing

@testable import MicroClient

@Suite("CacheControlInterceptor Tests")
struct CacheControlInterceptorTests {

    @Test("It should add Cache-Control header with no-cache policy")
    func addsCacheControlHeaderWithNoCachePolicy() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .noCache)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == "no-cache",
            "It should add Cache-Control header with no-cache policy"
        )
    }

    @Test("It should add Cache-Control header with max-age policy")
    func addsCacheControlHeaderWithMaxAgePolicy() async throws {
        // Given
        let maxAgeSeconds = 3600
        let interceptor = CacheControlInterceptor(policy: .maxAge(seconds: maxAgeSeconds))
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == "max-age=\(maxAgeSeconds)",
            "It should add Cache-Control header with max-age policy"
        )
    }

    @Test("It should add Cache-Control header with no-store policy")
    func addsCacheControlHeaderWithNoStorePolicy() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .noStore)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == "no-store",
            "It should add Cache-Control header with no-store policy"
        )
    }

    @Test("It should add Cache-Control header with custom policy")
    func addsCacheControlHeaderWithCustomPolicy() async throws {
        // Given
        let customPolicy = "must-revalidate, max-age=300"
        let interceptor = CacheControlInterceptor(policy: .custom(customPolicy))
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == customPolicy,
            "It should add Cache-Control header with custom policy"
        )
    }

    @Test("It should replace existing Cache-Control header")
    func replacesExistingCacheControlHeader() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .noCache)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("max-age=3600", forHTTPHeaderField: "Cache-Control")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == "no-cache",
            "It should replace existing Cache-Control header"
        )
    }

    @Test("It should handle max-age with zero seconds")
    func handlesMaxAgeWithZeroSeconds() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .maxAge(seconds: 0))
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == "max-age=0",
            "It should handle max-age with zero seconds"
        )
    }

    @Test("It should handle max-age with large numbers")
    func handlesMaxAgeWithLargeNumbers() async throws {
        // Given
        let largeMaxAge = 86400 // 24 hours
        let interceptor = CacheControlInterceptor(policy: .maxAge(seconds: largeMaxAge))
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader == "max-age=\(largeMaxAge)",
            "It should handle max-age with large numbers"
        )
    }

    @Test("It should handle empty custom policy")
    func handlesEmptyCustomPolicy() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .custom(""))
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let cacheControlHeader = request.value(forHTTPHeaderField: "Cache-Control")
        #expect(
            cacheControlHeader?.isEmpty == true,
            "It should handle empty custom policy"
        )
    }

    @Test("It should preserve other headers when adding Cache-Control header")
    func preservesOtherHeaders() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .maxAge(seconds: 1800))
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.value(forHTTPHeaderField: "Cache-Control") == "max-age=1800",
            "It should add Cache-Control header"
        )
        #expect(
            request.value(forHTTPHeaderField: "Content-Type") == "application/json",
            "It should preserve Content-Type header"
        )
        #expect(
            request.value(forHTTPHeaderField: "Authorization") == "Bearer token",
            "It should preserve Authorization header"
        )
    }

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let interceptor = CacheControlInterceptor(policy: .custom("private, max-age=600"))
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "GET"
        request.httpBody = nil
        request.timeoutInterval = 50.0

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.url == originalURL,
            "It should preserve the original URL"
        )
        #expect(
            request.httpMethod == "GET",
            "It should preserve the HTTP method"
        )
        #expect(
            request.httpBody == nil,
            "It should preserve the HTTP body"
        )
        #expect(
            request.timeoutInterval == 50.0,
            "It should preserve the timeout interval"
        )
        #expect(
            request.value(forHTTPHeaderField: "Cache-Control") == "private, max-age=600",
            "It should add the Cache-Control header"
        )
    }
}
