import Foundation
import Testing

@testable import MicroClient

@Suite("RequestIDInterceptor Tests")
struct RequestIDInterceptorTests {

    @Test("It should add request ID header with default header name")
    func addsRequestIDHeaderWithDefaultName() async throws {
        // Given
        let interceptor = RequestIDInterceptor()
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let requestIDHeader = request.value(forHTTPHeaderField: "X-Request-ID")
        #expect(
            requestIDHeader != nil,
            "It should add request ID to X-Request-ID header"
        )
        #expect(
            try UUID(uuidString: #require(requestIDHeader)) != nil,
            "It should be a valid UUID"
        )
    }

    @Test("It should add request ID header with custom header name")
    func addsRequestIDHeaderWithCustomName() async throws {
        // Given
        let customHeaderName = "Request-Trace-ID"
        let interceptor = RequestIDInterceptor(headerName: customHeaderName)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let requestIDHeader = request.value(forHTTPHeaderField: customHeaderName)
        #expect(
            requestIDHeader != nil,
            "It should add request ID to custom header name"
        )
        #expect(
            try UUID(uuidString: #require(requestIDHeader)) != nil,
            "It should be a valid UUID"
        )
    }

    @Test("It should generate unique IDs for different requests")
    func generatesUniqueIDsForDifferentRequests() async throws {
        // Given
        let interceptor = RequestIDInterceptor()
        var request1 = try URLRequest(url: #require(URL(string: "https://example.com/1")))
        var request2 = try URLRequest(url: #require(URL(string: "https://example.com/2")))

        // When
        request1 = try await interceptor.intercept(request1)
        request2 = try await interceptor.intercept(request2)

        // Then
        let requestID1 = request1.value(forHTTPHeaderField: "X-Request-ID")
        let requestID2 = request2.value(forHTTPHeaderField: "X-Request-ID")

        #expect(
            requestID1 != nil && requestID2 != nil,
            "Both requests should have request IDs"
        )
        #expect(
            requestID1 != requestID2,
            "Request IDs should be unique"
        )
    }

    @Test("It should replace existing request ID header")
    func replacesExistingRequestIDHeader() async throws {
        // Given
        let interceptor = RequestIDInterceptor()
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("old-request-id", forHTTPHeaderField: "X-Request-ID")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let requestIDHeader = request.value(forHTTPHeaderField: "X-Request-ID")
        #expect(
            requestIDHeader != "old-request-id",
            "It should replace existing request ID header"
        )
        #expect(
            try UUID(uuidString: #require(requestIDHeader)) != nil,
            "It should be a valid UUID"
        )
    }

    @Test("It should preserve other headers when adding request ID header")
    func preservesOtherHeaders() async throws {
        // Given
        let interceptor = RequestIDInterceptor()
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let requestIDHeader = request.value(forHTTPHeaderField: "X-Request-ID")
        #expect(
            requestIDHeader != nil,
            "It should add request ID header"
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

    @Test("It should handle empty custom header name")
    func handlesEmptyCustomHeaderName() async throws {
        // Given
        let interceptor = RequestIDInterceptor(headerName: "")
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let requestIDHeader = request.value(forHTTPHeaderField: "")
        #expect(
            requestIDHeader != nil,
            "It should add request ID even with empty header name"
        )
        #expect(
            try UUID(uuidString: #require(requestIDHeader)) != nil,
            "It should be a valid UUID"
        )
    }

    @Test("It should handle custom header name with special characters")
    func handlesCustomHeaderNameWithSpecialCharacters() async throws {
        // Given
        let specialHeaderName = "X-Request-ID_2024-Test"
        let interceptor = RequestIDInterceptor(headerName: specialHeaderName)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let requestIDHeader = request.value(forHTTPHeaderField: specialHeaderName)
        #expect(
            requestIDHeader != nil,
            "It should handle header names with special characters"
        )
        #expect(
            try UUID(uuidString: #require(requestIDHeader)) != nil,
            "It should be a valid UUID"
        )
    }

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let interceptor = RequestIDInterceptor(headerName: "Trace-ID")
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "POST"
        request.httpBody = Data("test body".utf8)
        request.timeoutInterval = 35.0

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
            request.timeoutInterval == 35.0,
            "It should preserve the timeout interval"
        )

        let requestIDHeader = request.value(forHTTPHeaderField: "Trace-ID")
        #expect(
            requestIDHeader != nil,
            "It should add the request ID header"
        )
        #expect(
            try UUID(uuidString: #require(requestIDHeader)) != nil,
            "It should be a valid UUID"
        )
    }
}
