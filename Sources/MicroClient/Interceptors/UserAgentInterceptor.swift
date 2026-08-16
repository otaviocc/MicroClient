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

/// An interceptor that adds a User-Agent header to HTTP requests.
///
/// This interceptor automatically adds a `User-Agent` header to outgoing requests,
/// which helps identify your application to APIs and can be useful for debugging
/// and analytics. You can either provide a custom user agent string or use
/// the convenience initializer that creates one from app name and version.
///
/// - Note: The User-Agent header is always added to requests when this interceptor is used.
/// - Warning: Existing User-Agent headers will be replaced.
public struct UserAgentInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let userAgent: String

    // MARK: - Life cycle

    public init(
        appName: String,
        version: String
    ) {
        userAgent = "\(appName)/\(version) (iOS)"
    }

    public init(customUserAgent: String) {
        userAgent = customUserAgent
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return newRequest
    }
}
