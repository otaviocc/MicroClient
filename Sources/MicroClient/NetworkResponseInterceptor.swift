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

/// A protocol for intercepting and processing network responses after they are received and decoded.
public protocol NetworkResponseInterceptor: Sendable {

    /// Intercepts and potentially modifies a network response.
    ///
    /// This method is called for each interceptor in the chain after the response has been successfully
    /// received and decoded. It can be used to log responses, collect metrics, validate response data,
    /// handle rate limiting, or transform the response.
    ///
    /// - Parameters:
    ///   - response: The `NetworkResponse` containing the decoded value and URLResponse.
    ///   - data: The raw response data before decoding.
    /// - Returns: A potentially modified `NetworkResponse`.
    /// - Throws: An error if the interception process fails. Throwing an error will propagate to the caller.
    func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel>
}
