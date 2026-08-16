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

/// A protocol for intercepting and modifying network requests before they are sent.
public protocol NetworkRequestInterceptor: Sendable {

    /// Intercepts and potentially modifies a URLRequest.
    ///
    /// This method is called for each interceptor in the chain. It can be used to add headers,
    /// modify the request body, or even perform asynchronous tasks like refreshing an authentication token.
    ///
    /// - Parameter request: The `URLRequest` to be processed.
    /// - Returns: A potentially modified `URLRequest`.
    /// - Throws: An error if the interception process fails. Throwing an error will cancel the entire request.
    func intercept(_ request: URLRequest) async throws -> URLRequest
}
