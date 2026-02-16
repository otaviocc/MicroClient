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

/// An interceptor that adds Accept headers to HTTP requests.
///
/// This interceptor automatically adds an `Accept` header to outgoing requests,
/// which tells the server what content types the client can handle. This is
/// useful for content negotiation with APIs that can return different formats.
/// The default accept type is `application/json`.
///
/// - Note: The Accept header is always added to requests when this interceptor is used.
/// - Warning: Existing Accept headers will be replaced.
public struct AcceptHeaderInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let acceptType: String

    // MARK: - Life cycle

    public init(acceptType: String = "application/json") {
        self.acceptType = acceptType
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(acceptType, forHTTPHeaderField: "Accept")
        return newRequest
    }
}
