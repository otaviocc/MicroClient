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

@Suite("APIKeyInterceptor Tests")
struct APIKeyInterceptorTests {

    @Test("It should add API key header with default header name")
    func addsAPIKeyHeaderWithDefaultName() async throws {
        // Given
        let apiKey = "test-api-key-123"
        let interceptor = APIKeyInterceptor(apiKey: apiKey)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let apiKeyHeader = request.value(forHTTPHeaderField: "X-API-Key")
        #expect(
            apiKeyHeader == apiKey,
            "It should add API key to X-API-Key header"
        )
    }

    @Test("It should add API key header with custom header name")
    func addsAPIKeyHeaderWithCustomName() async throws {
        // Given
        let apiKey = "custom-api-key-456"
        let customHeaderName = "API-Token"
        let interceptor = APIKeyInterceptor(apiKey: apiKey, headerName: customHeaderName)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let apiKeyHeader = request.value(forHTTPHeaderField: customHeaderName)
        #expect(
            apiKeyHeader == apiKey,
            "It should add API key to custom header name"
        )
    }

    @Test("It should replace existing API key header")
    func replacesExistingAPIKeyHeader() async throws {
        // Given
        let newAPIKey = "new-api-key-789"
        let interceptor = APIKeyInterceptor(apiKey: newAPIKey)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("old-api-key", forHTTPHeaderField: "X-API-Key")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let apiKeyHeader = request.value(forHTTPHeaderField: "X-API-Key")
        #expect(
            apiKeyHeader == newAPIKey,
            "It should replace existing API key header"
        )
    }

    @Test("It should preserve other headers when adding API key header")
    func preservesOtherHeaders() async throws {
        // Given
        let apiKey = "preserve-headers-key"
        let interceptor = APIKeyInterceptor(apiKey: apiKey)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.value(forHTTPHeaderField: "X-API-Key") == apiKey,
            "It should add API key header"
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

    @Test("It should handle empty API key")
    func handlesEmptyAPIKey() async throws {
        // Given
        let emptyAPIKey = ""
        let interceptor = APIKeyInterceptor(apiKey: emptyAPIKey)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let apiKeyHeader = request.value(forHTTPHeaderField: "X-API-Key")
        #expect(
            apiKeyHeader == emptyAPIKey,
            "It should handle empty API key"
        )
    }

    @Test("It should handle API key with special characters")
    func handlesAPIKeyWithSpecialCharacters() async throws {
        // Given
        let specialAPIKey = "api-key-with-special-chars!@#$%^&*()"
        let interceptor = APIKeyInterceptor(apiKey: specialAPIKey)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let apiKeyHeader = request.value(forHTTPHeaderField: "X-API-Key")
        #expect(
            apiKeyHeader == specialAPIKey,
            "It should handle API keys with special characters"
        )
    }

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let apiKey = "url-preservation-key"
        let interceptor = APIKeyInterceptor(apiKey: apiKey)
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
            request.value(forHTTPHeaderField: "X-API-Key") == apiKey,
            "It should add the API key header"
        )
    }
}
