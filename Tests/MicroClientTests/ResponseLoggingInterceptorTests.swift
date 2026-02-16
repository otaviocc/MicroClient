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

@Suite("ResponseLoggingInterceptor Tests")
struct ResponseLoggingInterceptorTests {

    @Test("It should log response status code and headers")
    func logsResponseStatusAndHeaders() async throws {
        // Given
        let logger = LoggerMock()
        let interceptor = ResponseLoggingInterceptor(logger: logger)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )
        let data = Data("test response".utf8)
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        _ = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            logger.loggedMessages.count >= 2,
            "It should log at least status and headers"
        )
        #expect(
            logger.loggedMessages.contains { $0.message.contains("Status: 200") },
            "It should log the status code"
        )
        #expect(
            logger.loggedMessages.contains { $0.message.contains("Headers:") },
            "It should log the headers"
        )
    }

    @Test("It should log response body")
    func logsResponseBody() async throws {
        // Given
        let logger = LoggerMock()
        let interceptor = ResponseLoggingInterceptor(logger: logger)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let bodyString = "test response body"
        let data = Data(bodyString.utf8)
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        _ = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            logger.loggedMessages.contains { $0.message.contains("Body:") && $0.message.contains(bodyString) },
            "It should log the response body"
        )
    }

    @Test("It should use specified log level")
    func usesSpecifiedLogLevel() async throws {
        // Given
        let logger = LoggerMock()
        let customLogLevel: NetworkLogLevel = .warning
        let interceptor = ResponseLoggingInterceptor(logger: logger, logLevel: customLogLevel)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let data = Data()
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        _ = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            logger.loggedMessages.allSatisfy { $0.level == customLogLevel },
            "It should use the specified log level"
        )
    }

    @Test("It should return the same response unchanged")
    func returnsSameResponse() async throws {
        // Given
        let logger = LoggerMock()
        let interceptor = ResponseLoggingInterceptor(logger: logger)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let data = Data()
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should return the same response"
        )
    }
}
