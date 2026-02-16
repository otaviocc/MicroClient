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

@Suite("AcceptHeaderInterceptor Tests")
struct AcceptHeaderInterceptorTests {

    @Test("It should add Accept header with default accept type")
    func addsAcceptHeaderWithDefaultType() async throws {
        // Given
        let interceptor = AcceptHeaderInterceptor()
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

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
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

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
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
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
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
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
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

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
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

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
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))

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
