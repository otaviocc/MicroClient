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

/// An interceptor that adds API key authentication to HTTP requests.
///
/// This interceptor automatically adds an API key header to outgoing requests.
/// The header name is configurable, with `X-API-Key` being the default.
/// This is commonly used for API authentication where a static key is required.
///
/// - Note: The API key is always added to requests when this interceptor is used.
/// - Warning: Existing headers with the same name will be replaced.
public struct APIKeyInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let apiKey: String
    private let headerName: String

    // MARK: - Life cycle

    public init(
        apiKey: String,
        headerName: String = "X-API-Key"
    ) {
        self.apiKey = apiKey
        self.headerName = headerName
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(apiKey, forHTTPHeaderField: headerName)
        return newRequest
    }
}
