import Testing
import Foundation

@testable import MicroClient

@Suite("ContentTypeInterceptor Tests")
struct ContentTypeInterceptorTests {

    @Test("It should add Content-Type header when request has body")
    func addsContentTypeHeaderWhenRequestHasBody() async throws {
        // Given
        let interceptor = ContentTypeInterceptor()
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.httpBody = Data("test body".utf8)

        // When
        request = try await interceptor.intercept(request)

        // Then
        let contentTypeHeader = request.value(forHTTPHeaderField: "Content-Type")
        #expect(
            contentTypeHeader == "application/json",
            "It should add default Content-Type header when request has body"
        )
    }

    @Test("It should not add Content-Type header when request has no body")
    func doesNotAddContentTypeHeaderWhenRequestHasNoBody() async throws {
        // Given
        let interceptor = ContentTypeInterceptor()
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let contentTypeHeader = request.value(forHTTPHeaderField: "Content-Type")
        #expect(
            contentTypeHeader == nil,
            "It should not add Content-Type header when request has no body"
        )
    }

    @Test("It should add custom Content-Type header when request has body")
    func addsCustomContentTypeHeaderWhenRequestHasBody() async throws {
        // Given
        let customContentType = "application/xml"
        let interceptor = ContentTypeInterceptor(contentType: customContentType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.httpBody = Data("<xml>data</xml>".utf8)

        // When
        request = try await interceptor.intercept(request)

        // Then
        let contentTypeHeader = request.value(forHTTPHeaderField: "Content-Type")
        #expect(
            contentTypeHeader == customContentType,
            "It should add custom Content-Type header when request has body"
        )
    }

    @Test("It should replace existing Content-Type header when request has body")
    func replacesExistingContentTypeHeaderWhenRequestHasBody() async throws {
        // Given
        let newContentType = "text/plain"
        let interceptor = ContentTypeInterceptor(contentType: newContentType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.httpBody = Data("plain text".utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let contentTypeHeader = request.value(forHTTPHeaderField: "Content-Type")
        #expect(
            contentTypeHeader == newContentType,
            "It should replace existing Content-Type header when request has body"
        )
    }

    @Test("It should preserve existing Content-Type header when request has no body")
    func preservesExistingContentTypeHeaderWhenRequestHasNoBody() async throws {
        // Given
        let existingContentType = "application/json"
        let interceptor = ContentTypeInterceptor(contentType: "text/plain")
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.setValue(existingContentType, forHTTPHeaderField: "Content-Type")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let contentTypeHeader = request.value(forHTTPHeaderField: "Content-Type")
        #expect(
            contentTypeHeader == existingContentType,
            "It should preserve existing Content-Type header when request has no body"
        )
    }

    @Test("It should handle empty body")
    func handlesEmptyBody() async throws {
        // Given
        let interceptor = ContentTypeInterceptor()
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.httpBody = Data()

        // When
        request = try await interceptor.intercept(request)

        // Then
        let contentTypeHeader = request.value(forHTTPHeaderField: "Content-Type")
        #expect(
            contentTypeHeader == "application/json",
            "It should add Content-Type header even for empty body"
        )
    }

    @Test("It should preserve other headers when adding Content-Type")
    func preservesOtherHeaders() async throws {
        // Given
        let interceptor = ContentTypeInterceptor()
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.httpBody = Data("test body".utf8)
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
        request.setValue("custom-value", forHTTPHeaderField: "X-Custom-Header")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.value(forHTTPHeaderField: "Content-Type") == "application/json",
            "It should add Content-Type header"
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

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let interceptor = ContentTypeInterceptor(contentType: "application/hal+json")
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "PATCH"
        request.httpBody = Data("patch data".utf8)
        request.timeoutInterval = 25.0

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.url == originalURL,
            "It should preserve the original URL"
        )
        #expect(
            request.httpMethod == "PATCH",
            "It should preserve the HTTP method"
        )
        #expect(
            request.httpBody == Data("patch data".utf8),
            "It should preserve the HTTP body"
        )
        #expect(
            request.timeoutInterval == 25.0,
            "It should preserve the timeout interval"
        )
        #expect(
            request.value(forHTTPHeaderField: "Content-Type") == "application/hal+json",
            "It should add the Content-Type header"
        )
    }
}
