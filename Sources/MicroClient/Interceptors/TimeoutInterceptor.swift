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

/// An interceptor that configures custom timeout intervals for HTTP requests.
///
/// This interceptor automatically sets the timeout interval for outgoing requests.
/// This is useful for configuring different timeout behaviors for different
/// types of requests or APIs that have known performance characteristics.
///
/// - Note: The timeout interval is always applied to requests when this interceptor is used.
/// - Warning: Existing timeout intervals will be replaced.
public struct TimeoutInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let timeout: TimeInterval

    // MARK: - Life cycle

    public init(timeout: TimeInterval) {
        self.timeout = timeout
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.timeoutInterval = timeout
        return newRequest
    }
}
