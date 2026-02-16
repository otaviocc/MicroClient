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

/// An interceptor that adds Content-Type headers to HTTP requests with a body.
///
/// This interceptor automatically adds a `Content-Type` header to outgoing requests
/// that have an HTTP body. This is commonly used for JSON APIs where you want to
/// ensure all requests with bodies are properly labeled. The default content type
/// is `application/json`, but it can be customized.
///
/// - Note: Content-Type is only added to requests that have an HTTP body.
/// - Warning: Existing Content-Type headers will be replaced.
public struct ContentTypeInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let contentType: String

    // MARK: - Life cycle

    public init(contentType: String = "application/json") {
        self.contentType = contentType
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request

        if newRequest.httpBody != nil {
            newRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        return newRequest
    }
}
