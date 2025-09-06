import Foundation
import Testing

@testable import MicroClient

@Suite("BasicAuthInterceptor Tests")
struct BasicAuthInterceptorTests {

    @Test("It should add Basic Authorization header with static credentials")
    func addsBasicAuthorizationHeaderWithStaticCredentials() async throws {
        // Given
        let username = "testuser"
        let password = "testpassword"
        let interceptor = BasicAuthInterceptor(username: username, password: password)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "\(username):\(password)"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should add Basic Authorization header with base64 encoded credentials"
        )
    }

    @Test("It should add Basic Authorization header with async credentials provider")
    func addsBasicAuthorizationHeaderWithAsyncProvider() async throws {
        // Given
        let username = "asyncuser"
        let password = "asyncpassword"
        let interceptor = BasicAuthInterceptor {
            // Simulate async credential retrieval
            try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
            return (username: username, password: password)
        }
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "\(username):\(password)"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should add Basic Authorization header from async provider"
        )
    }

    @Test("It should not add Authorization header when credentials provider returns nil")
    func doesNotAddAuthorizationHeaderWhenProviderReturnsNil() async throws {
        // Given
        let interceptor = BasicAuthInterceptor {
            nil // No credentials available
        }
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == nil,
            "It should not add Authorization header when credentials provider returns nil"
        )
    }

    @Test("It should replace existing Authorization header")
    func replacesExistingAuthorizationHeader() async throws {
        // Given
        let username = "newuser"
        let password = "newpassword"
        let interceptor = BasicAuthInterceptor(username: username, password: password)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "\(username):\(password)"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should replace existing Authorization header with Basic auth"
        )
    }

    @Test("It should preserve existing Authorization header when provider returns nil")
    func preservesExistingAuthorizationHeaderWhenProviderReturnsNil() async throws {
        // Given
        let existingToken = "Bearer existing-token"
        let interceptor = BasicAuthInterceptor {
            nil // No credentials available
        }
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue(existingToken, forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader == existingToken,
            "It should preserve existing Authorization header when provider returns nil"
        )
    }

    @Test("It should handle empty username and password")
    func handlesEmptyUsernameAndPassword() async throws {
        // Given
        let username = ""
        let password = ""
        let interceptor = BasicAuthInterceptor(username: username, password: password)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = ":"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should handle empty username and password"
        )
    }

    @Test("It should handle username and password with special characters")
    func handlesUsernameAndPasswordWithSpecialCharacters() async throws {
        // Given
        let username = "user@domain.com"
        let password = "p@ssw0rd!@#$%^&*()"
        let interceptor = BasicAuthInterceptor(username: username, password: password)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "\(username):\(password)"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should handle username and password with special characters"
        )
    }

    @Test("It should handle username with colon character")
    func handlesUsernameWithColonCharacter() async throws {
        // Given
        let username = "user:name"
        let password = "password"
        let interceptor = BasicAuthInterceptor(username: username, password: password)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "\(username):\(password)"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should handle username with colon character"
        )
    }

    @Test("It should handle unicode characters in credentials")
    func handlesUnicodeCharactersInCredentials() async throws {
        // Given
        let username = "üser"
        let password = "pässwörd"
        let interceptor = BasicAuthInterceptor(username: username, password: password)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "\(username):\(password)"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should handle unicode characters in credentials"
        )
    }

    @Test("It should preserve other headers when adding Authorization header")
    func preservesOtherHeaders() async throws {
        // Given
        let interceptor = BasicAuthInterceptor(username: "testuser", password: "testpass")
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("custom-value", forHTTPHeaderField: "X-Custom-Header")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(
            authHeader?.hasPrefix("Basic ") == true,
            "It should add Basic Authorization header"
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

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let interceptor = BasicAuthInterceptor(username: "apiuser", password: "apipass")
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "POST"
        request.httpBody = Data("test body".utf8)
        request.timeoutInterval = 60.0

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
            request.timeoutInterval == 60.0,
            "It should preserve the timeout interval"
        )

        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        let credentials = "apiuser:apipass"
        let expectedBase64 = Data(credentials.utf8).base64EncodedString()
        #expect(
            authHeader == "Basic \(expectedBase64)",
            "It should add the Basic Authorization header"
        )
    }
}
