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

@Suite("RetryAfterInterceptor Tests")
struct RetryAfterInterceptorTests {

    @Test("It should throw RetryAfterError for 429 status with seconds")
    func throwsErrorFor429WithSeconds() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 429,
            httpVersion: "HTTP/1.1",
            headerFields: ["Retry-After": "60"]
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When/Then
        do {
            _ = try await interceptor.intercept(networkResponse, Data())
            #expect(Bool(false), "It should throw RetryAfterError")
        } catch let error as RetryAfterError {
            #expect(
                error.statusCode == 429,
                "It should include the status code"
            )
            #expect(
                error.retryAfterSeconds == 60,
                "It should parse seconds correctly"
            )
            #expect(
                error.retryAfterDate == nil,
                "It should not have a date when seconds are provided"
            )
        }
    }

    @Test("It should throw RetryAfterError for 503 status with seconds")
    func throwsErrorFor503WithSeconds() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 503,
            httpVersion: "HTTP/1.1",
            headerFields: ["Retry-After": "120"]
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When/Then
        do {
            _ = try await interceptor.intercept(networkResponse, Data())
            #expect(Bool(false), "It should throw RetryAfterError")
        } catch let error as RetryAfterError {
            #expect(
                error.statusCode == 503,
                "It should include the status code"
            )
            #expect(
                error.retryAfterSeconds == 120,
                "It should parse seconds correctly"
            )
        }
    }

    @Test("It should throw RetryAfterError for 429 status with HTTP date")
    func throwsErrorFor429WithHTTPDate() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 429,
            httpVersion: "HTTP/1.1",
            headerFields: ["Retry-After": "Wed, 21 Oct 2025 07:28:00 GMT"]
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When/Then
        do {
            _ = try await interceptor.intercept(networkResponse, Data())
            #expect(Bool(false), "It should throw RetryAfterError")
        } catch let error as RetryAfterError {
            #expect(
                error.statusCode == 429,
                "It should include the status code"
            )
            #expect(
                error.retryAfterDate != nil,
                "It should parse the date"
            )
            #expect(
                error.retryAfterSeconds == nil,
                "It should not have seconds when a date is provided"
            )
        }
    }

    @Test("It should pass through responses without Retry-After header")
    func passesResponsesWithoutRetryAfterHeader() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 429,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should return the response unchanged"
        )
    }

    @Test("It should pass through responses with non-rate-limit status codes")
    func passesNonRateLimitStatusCodes() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Retry-After": "60"]
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should return the response unchanged for non-rate-limit status codes"
        )
    }

    @Test("It should handle non-HTTP responses")
    func handlesNonHTTPResponses() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com"))
        let response = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let networkResponse = NetworkResponse(
            value: VoidResponse(),
            response: response
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should return the response unchanged for non-HTTP responses"
        )
    }

    @Test("It should pass through malformed Retry-After values")
    func passesMalformedRetryAfterValues() async throws {
        // Given
        let interceptor = RetryAfterInterceptor()
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 429,
            httpVersion: "HTTP/1.1",
            headerFields: ["Retry-After": "invalid-value"]
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should return the response unchanged for malformed Retry-After values"
        )
    }
}
