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

/// A protocol for receiving metrics collected from network responses.
public protocol MetricsCollector: Sendable {

    /// Called when response metrics are collected.
    /// - Parameter metrics: The collected response metrics.
    func collect(
        _ metrics: ResponseMetrics
    ) async
}

/// Metrics collected from a network response.
public struct ResponseMetrics: Sendable {

    // MARK: - Properties

    public let statusCode: Int?
    public let responseSize: Int
    public let url: URL?
    public let httpMethod: String?

    // MARK: - Life cycle

    /// Initializes response metrics.
    /// - Parameters:
    ///   - statusCode: The HTTP status code.
    ///   - responseSize: The size of the response body in bytes.
    ///   - url: The URL of the request.
    ///   - httpMethod: The HTTP method used.
    public init(
        statusCode: Int?,
        responseSize: Int,
        url: URL?,
        httpMethod: String?
    ) {
        self.statusCode = statusCode
        self.responseSize = responseSize
        self.url = url
        self.httpMethod = httpMethod
    }
}

/// An interceptor that collects metrics from network responses.
///
/// This interceptor extracts key metrics from responses such as status codes,
/// response sizes, and timing information, then forwards them to a metrics collector
/// for aggregation, monitoring, or analytics purposes.
public struct MetricsCollectionInterceptor: NetworkResponseInterceptor {

    // MARK: - Properties

    private let collector: MetricsCollector

    // MARK: - Life cycle

    public init(
        collector: MetricsCollector
    ) {
        self.collector = collector
    }

    // MARK: - Public

    public func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        let httpResponse = response.response as? HTTPURLResponse

        let metrics = ResponseMetrics(
            statusCode: httpResponse?.statusCode,
            responseSize: data.count,
            url: httpResponse?.url,
            httpMethod: httpResponse?.value(forHTTPHeaderField: "X-HTTP-Method")
        )

        await collector.collect(metrics)

        return response
    }
}
