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

/// Error thrown when a Retry-After header indicates the client should wait before retrying.
public struct RetryAfterError: Error {

    // MARK: - Properties

    public let retryAfterDate: Date?
    public let retryAfterSeconds: TimeInterval?
    public let statusCode: Int

    // MARK: - Life cycle

    public init(
        retryAfterDate: Date? = nil,
        retryAfterSeconds: TimeInterval? = nil,
        statusCode: Int
    ) {
        self.retryAfterDate = retryAfterDate
        self.retryAfterSeconds = retryAfterSeconds
        self.statusCode = statusCode
    }
}

/// An interceptor that handles rate limiting by parsing the Retry-After header.
///
/// This interceptor checks for 429 (Too Many Requests) and 503 (Service Unavailable) status codes
/// and parses the Retry-After header to determine when the client should retry the request.
/// When detected, it throws a `RetryAfterError` containing the retry timing information.
public struct RetryAfterInterceptor: NetworkResponseInterceptor {

    // MARK: - Properties

    private static let retryAfterHeader = "Retry-After"

    // MARK: - Life cycle

    public init() {}

    // MARK: - Public

    public func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response
        }

        // Check for rate limit or service unavailable status codes
        guard httpResponse.statusCode == 429 || httpResponse.statusCode == 503 else {
            return response
        }

        // Parse Retry-After header
        guard let retryAfterValue = httpResponse.value(forHTTPHeaderField: Self.retryAfterHeader) else {
            return response
        }

        // Try to parse as seconds (integer)
        if let seconds = TimeInterval(retryAfterValue) {
            throw RetryAfterError(
                retryAfterSeconds: seconds,
                statusCode: httpResponse.statusCode
            )
        }

        // Try to parse as HTTP date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")

        if let date = dateFormatter.date(from: retryAfterValue) {
            throw RetryAfterError(
                retryAfterDate: date,
                statusCode: httpResponse.statusCode
            )
        }

        return response
    }
}
