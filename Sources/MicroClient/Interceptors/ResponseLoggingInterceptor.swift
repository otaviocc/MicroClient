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

/// An interceptor that logs response information including status code, headers, and body data.
///
/// This interceptor provides structured logging of HTTP responses to aid in debugging and monitoring.
/// It logs the HTTP status code, response headers, and the response body (if available).
public struct ResponseLoggingInterceptor: NetworkResponseInterceptor {

    // MARK: - Properties

    private let logger: NetworkLogger
    private let logLevel: NetworkLogLevel

    // MARK: - Life cycle

    public init(
        logger: NetworkLogger,
        logLevel: NetworkLogLevel = .debug
    ) {
        self.logger = logger
        self.logLevel = logLevel
    }

    // MARK: - Public

    public func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        if let httpResponse = response.response as? HTTPURLResponse {
            logger.log(
                level: logLevel,
                message: "Response interceptor - Status: \(httpResponse.statusCode)"
            )
            logger.log(
                level: logLevel,
                message: "Response interceptor - Headers: \(httpResponse.allHeaderFields)"
            )
        }

        if let bodyString = String(data: data, encoding: .utf8) {
            logger.log(
                level: logLevel,
                message: "Response interceptor - Body: \(bodyString)"
            )
        }

        return response
    }
}
