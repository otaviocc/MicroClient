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

@Suite("UserAgentInterceptor Tests")
struct UserAgentInterceptorTests {

    @Test("It should add User-Agent header with app name and version")
    func addsUserAgentHeaderWithAppNameAndVersion() async throws {
        // Given
        let appName = "TestApp"
        let version = "1.0.0"
        let interceptor = UserAgentInterceptor(appName: appName, version: version)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let userAgentHeader = request.value(forHTTPHeaderField: "User-Agent")
        #expect(
            userAgentHeader == "\(appName)/\(version) (iOS)",
            "It should add User-Agent header with app name and version"
        )
    }

    @Test("It should add custom User-Agent header")
    func addsCustomUserAgentHeader() async throws {
        // Given
        let customUserAgent = "MyCustomClient/2.1 (macOS; Intel)"
        let interceptor = UserAgentInterceptor(customUserAgent: customUserAgent)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let userAgentHeader = request.value(forHTTPHeaderField: "User-Agent")
        #expect(
            userAgentHeader == customUserAgent,
            "It should add custom User-Agent header"
        )
    }

    @Test("It should replace existing User-Agent header")
    func replacesExistingUserAgentHeader() async throws {
        // Given
        let newUserAgent = "NewApp/3.0 (iOS)"
        let interceptor = UserAgentInterceptor(customUserAgent: newUserAgent)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("OldApp/1.0", forHTTPHeaderField: "User-Agent")

        // When
        request = try await interceptor.intercept(request)

        // Then
        let userAgentHeader = request.value(forHTTPHeaderField: "User-Agent")
        #expect(
            userAgentHeader == newUserAgent,
            "It should replace existing User-Agent header"
        )
    }

    @Test("It should preserve other headers when adding User-Agent header")
    func preservesOtherHeaders() async throws {
        // Given
        let interceptor = UserAgentInterceptor(appName: "TestApp", version: "1.0")
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.value(forHTTPHeaderField: "User-Agent") == "TestApp/1.0 (iOS)",
            "It should add User-Agent header"
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

    @Test("It should handle empty app name and version")
    func handlesEmptyAppNameAndVersion() async throws {
        // Given
        let interceptor = UserAgentInterceptor(appName: "", version: "")
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let userAgentHeader = request.value(forHTTPHeaderField: "User-Agent")
        #expect(
            userAgentHeader == "/ (iOS)",
            "It should handle empty app name and version"
        )
    }

    @Test("It should handle app name and version with special characters")
    func handlesAppNameAndVersionWithSpecialCharacters() async throws {
        // Given
        let appName = "Test-App_2024"
        let version = "1.0-beta.1"
        let interceptor = UserAgentInterceptor(appName: appName, version: version)
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

        // When
        request = try await interceptor.intercept(request)

        // Then
        let userAgentHeader = request.value(forHTTPHeaderField: "User-Agent")
        #expect(
            userAgentHeader == "\(appName)/\(version) (iOS)",
            "It should handle app names and versions with special characters"
        )
    }

    @Test("It should preserve request URL and other properties")
    func preservesRequestProperties() async throws {
        // Given
        let interceptor = UserAgentInterceptor(appName: "TestApp", version: "1.0")
        let originalURL = try #require(URL(string: "https://example.com/api/endpoint"))
        var request = URLRequest(url: originalURL)
        request.httpMethod = "PUT"
        request.httpBody = Data("test body".utf8)
        request.timeoutInterval = 45.0

        // When
        request = try await interceptor.intercept(request)

        // Then
        #expect(
            request.url == originalURL,
            "It should preserve the original URL"
        )
        #expect(
            request.httpMethod == "PUT",
            "It should preserve the HTTP method"
        )
        #expect(
            request.httpBody == Data("test body".utf8),
            "It should preserve the HTTP body"
        )
        #expect(
            request.timeoutInterval == 45.0,
            "It should preserve the timeout interval"
        )
        #expect(
            request.value(forHTTPHeaderField: "User-Agent") == "TestApp/1.0 (iOS)",
            "It should add the User-Agent header"
        )
    }
}
