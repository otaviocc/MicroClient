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

@Suite("MetricsCollectionInterceptor Tests")
struct MetricsCollectionInterceptorTests {

    @Test("It should collect response metrics with status code")
    func collectsMetricsWithStatusCode() async throws {
        // Given
        let collector = MetricsCollectorMock()
        let interceptor = MetricsCollectionInterceptor(collector: collector)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let data = Data("test data".utf8)
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        _ = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            collector.collectCalled == true,
            "It should call the collector"
        )
        #expect(
            collector.lastMetrics?.statusCode == 200,
            "It should collect the status code"
        )
    }

    @Test("It should collect response size")
    func collectsResponseSize() async throws {
        // Given
        let collector = MetricsCollectorMock()
        let interceptor = MetricsCollectionInterceptor(collector: collector)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let dataString = "test data with specific length"
        let data = Data(dataString.utf8)
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        _ = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            collector.lastMetrics?.responseSize == data.count,
            "It should collect the correct response size"
        )
    }

    @Test("It should collect URL information")
    func collectsURLInformation() async throws {
        // Given
        let collector = MetricsCollectorMock()
        let interceptor = MetricsCollectionInterceptor(collector: collector)
        let url = try #require(URL(string: "https://example.com/api/endpoint"))
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
            collector.lastMetrics?.url == url,
            "It should collect the URL"
        )
    }

    @Test("It should handle non-HTTP responses")
    func handlesNonHTTPResponses() async throws {
        // Given
        let collector = MetricsCollectorMock()
        let interceptor = MetricsCollectionInterceptor(collector: collector)
        let url = try #require(URL(string: "https://example.com"))
        let response = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let data = Data()
        let networkResponse = NetworkResponse(
            value: VoidResponse(),
            response: response
        )

        // When
        _ = try await interceptor.intercept(networkResponse, data)

        // Then
        #expect(
            collector.collectCalled == true,
            "It should still collect metrics"
        )
        #expect(
            collector.lastMetrics?.statusCode == nil,
            "It should have nil status code for non-HTTP responses"
        )
    }

    @Test("It should return the same response unchanged")
    func returnsSameResponse() async throws {
        // Given
        let collector = MetricsCollectorMock()
        let interceptor = MetricsCollectionInterceptor(collector: collector)
        let url = try #require(URL(string: "https://example.com"))
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

    @Test("It should collect metrics for multiple requests")
    func collectsMetricsForMultipleRequests() async throws {
        // Given
        let collector = MetricsCollectorMock()
        let interceptor = MetricsCollectionInterceptor(collector: collector)
        let url = try #require(URL(string: "https://example.com"))

        // When
        for statusCode in [200, 201, 404] {
            let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            let networkResponse = try NetworkResponse(
                value: VoidResponse(),
                response: #require(httpResponse)
            )
            _ = try await interceptor.intercept(networkResponse, Data())
        }

        // Then
        #expect(
            collector.collectCallCount == 3,
            "It should collect metrics for all requests"
        )
        #expect(
            collector.collectedMetrics.count == 3,
            "It should store all collected metrics"
        )
    }
}
