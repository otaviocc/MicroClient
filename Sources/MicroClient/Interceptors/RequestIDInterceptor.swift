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

/// An interceptor that adds unique request IDs to HTTP requests.
///
/// This interceptor automatically adds a unique identifier header to outgoing requests.
/// Each request gets a UUID that can be used for tracing, debugging, and correlating
/// requests with responses in logs. The header name is configurable, with `X-Request-ID`
/// being the default.
///
/// - Note: A new UUID is generated for each request when this interceptor is used.
/// - Warning: Existing headers with the same name will be replaced.
public struct RequestIDInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let headerName: String

    // MARK: - Life cycle

    public init(headerName: String = "X-Request-ID") {
        self.headerName = headerName
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        let requestID = UUID().uuidString
        newRequest.setValue(requestID, forHTTPHeaderField: headerName)
        return newRequest
    }
}
