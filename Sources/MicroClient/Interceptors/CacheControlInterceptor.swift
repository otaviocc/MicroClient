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

/// An interceptor that adds Cache-Control headers to HTTP requests.
///
/// This interceptor automatically adds a `Cache-Control` header to outgoing requests,
/// which controls caching behavior. You can specify different cache policies such as
/// no-cache, max-age, no-store, or provide custom cache control directives.
///
/// - Note: The Cache-Control header is always added to requests when this interceptor is used.
/// - Warning: Existing Cache-Control headers will be replaced.
public struct CacheControlInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    public enum CachePolicy: Sendable {

        case noCache
        case maxAge(seconds: Int)
        case noStore
        case custom(String)

        var headerValue: String {
            switch self {
            case .noCache: "no-cache"
            case let .maxAge(seconds): "max-age=\(seconds)"
            case .noStore: "no-store"
            case let .custom(value): value
            }
        }
    }

    private let policy: CachePolicy

    // MARK: - Life cycle

    public init(policy: CachePolicy) {
        self.policy = policy
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(policy.headerValue, forHTTPHeaderField: "Cache-Control")
        return newRequest
    }
}
