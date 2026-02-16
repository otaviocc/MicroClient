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

/// An interceptor that adds Bearer token authorization to HTTP requests.
///
/// This interceptor automatically adds an `Authorization` header with a Bearer token
/// to outgoing requests. The token is provided through an asynchronous closure,
/// allowing for dynamic token retrieval or refresh.
///
/// - Note: If the token provider returns `nil`, no Authorization header is added.
/// - Warning: Existing Authorization headers will be replaced when a token is provided.
public struct BearerAuthorizationInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let tokenProvider: @Sendable () async -> String?

    // MARK: - Life cycle

    public init(
        tokenProvider: @escaping @Sendable () async -> String?
    ) {
        self.tokenProvider = tokenProvider
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request

        if let token = await tokenProvider() {
            newRequest.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return newRequest
    }
}
