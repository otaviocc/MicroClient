import Testing
import Foundation

@testable import MicroClient

@Suite("AcceptHeaderInterceptor Tests")
struct AcceptHeaderInterceptorTests {

    @Test("It should add Accept header with default accept type")
    func addsAcceptHeaderWithDefaultType() async throws {
        // Given
        let interceptor = AcceptHeaderInterceptor()
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let acceptHeader = request.value(forHTTPHeaderField: "Accept")
        #expect(
            acceptHeader == "application/json",
            "It should add default Accept header"
        )
    }

    @Test("It should add Accept header with custom accept type")
    func addsAcceptHeaderWithCustomType() async throws {
        // Given
        let customAcceptType = "application/xml"
        let interceptor = AcceptHeaderInterceptor(acceptType: customAcceptType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let acceptHeader = request.value(forHTTPHeaderField: "Accept")
        #expect(
            acceptHeader == customAcceptType,
            "It should add custom Accept header"
        )
    }

    @Test("It should replace existing Accept header")
    func replacesExistingAcceptHeader() async throws {
        // Given
        let newAcceptType = "text/plain"
        let interceptor = AcceptHeaderInterceptor(acceptType: newAcceptType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let acceptHeader = request.value(forHTTPHeaderField: "Accept")
        #expect(
            acceptHeader == newAcceptType,
            "It should replace existing Accept header"
        )
    }

    @Test("It should preserve other headers when adding Accept header")
    func preservesOtherHeaders() async throws {
        // Given
        let interceptor = AcceptHeaderInterceptor(acceptType: "application/hal+json")
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.value(forHTTPHeaderField: "Accept") == "application/hal+json",
            "It should add Accept header"
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

    @Test("It should handle empty accept type")
    func handlesEmptyAcceptType() async throws {
        // Given
        let emptyAcceptType = ""
        let interceptor = AcceptHeaderInterceptor(acceptType: emptyAcceptType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let acceptHeader = request.value(forHTTPHeaderField: "Accept")
        #expect(
            acceptHeader == emptyAcceptType,
            "It should handle empty accept type"
        )
    }

    @Test("It should handle accept type with multiple media types")
    func handlesAcceptTypeWithMultipleMediaTypes() async throws {
        // Given
        let multipleAcceptType = "application/json, application/xml; q=0.9, text/plain; q=0.8"
        let interceptor = AcceptHeaderInterceptor(acceptType: multipleAcceptType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let acceptHeader = request.value(forHTTPHeaderField: "Accept")
        #expect(
            acceptHeader == multipleAcceptType,
            "It should handle accept types with multiple media types and quality values"
        )
    }

    @Test("It should handle accept type with special characters")
    func handlesAcceptTypeWithSpecialCharacters() async throws {
        // Given
        let specialAcceptType = "application/vnd.api+json; charset=utf-8"
        let interceptor = AcceptHeaderInterceptor(acceptType: specialAcceptType)
        var request = URLRequest(url: try #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let acceptHeader = request.value(forHTTPHeaderField: "Accept")
        #expect(
            acceptHeader == specialAcceptType,
            "It should handle accept types with special characters"
        )
    }

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let interceptor = AcceptHeaderInterceptor(acceptType: "image/png, image/jpeg")
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "GET"
        request.httpBody = nil
        request.timeoutInterval = 40.0

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
            request.timeoutInterval == 40.0,
            "It should preserve the timeout interval"
        )
        #expect(
            request.value(forHTTPHeaderField: "Accept") == "image/png, image/jpeg",
            "It should add the Accept header"
        )
    }
}
