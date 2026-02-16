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

/// An interceptor that validates HTTP status codes against a custom range or set of acceptable codes.
///
/// This interceptor provides flexible status code validation beyond the default 200-299 range.
/// It can be configured to accept specific status codes or ranges, making it useful for APIs
/// that use non-standard success codes (e.g., 304 Not Modified, or custom 2xx codes).
public struct StatusCodeValidationInterceptor: NetworkResponseInterceptor {

    // MARK: - Properties

    private let acceptableStatusCodes: Set<Int>

    // MARK: - Life cycle

    public init(
        acceptableStatusCodes: Set<Int>
    ) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }

    public init(
        acceptableRange: ClosedRange<Int>
    ) {
        acceptableStatusCodes = Set(acceptableRange)
    }

    public init(
        ranges: [ClosedRange<Int>]
    ) {
        var codes = Set<Int>()
        for range in ranges {
            codes.formUnion(range)
        }
        acceptableStatusCodes = codes
    }

    // MARK: - Public

    public func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response
        }

        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            throw NetworkClientError.unacceptableStatusCode(
                statusCode: httpResponse.statusCode,
                response: httpResponse,
                data: data
            )
        }

        return response
    }
}
