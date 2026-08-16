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

/// An enum representing possible errors that can occur during a network request.
public enum NetworkClientError: Error {

    /// The URL for the request was malformed or invalid.
    case malformedURL

    /// The request failed due to an underlying transport error, such as a lost network connection.
    /// The associated `Error` value contains the original error from the URLSession.
    case transportError(Error)

    /// The server returned a response with an HTTP status code indicating an error (i.e., not in the 200-299 range).
    /// - `statusCode`: The HTTP status code returned by the server.
    /// - `response`: The metadata associated with the HTTP response.
    /// - `data`: The raw response body, which may contain more specific error details from the server.
    case unacceptableStatusCode(statusCode: Int, response: URLResponse, data: Data?)

    /// The response body could not be decoded into the expected `Decodable` type.
    /// The associated `Error` value contains the original decoding error.
    case decodingError(Error)

    /// The response body could not be encoded into the expected `Encodable` type.
    /// The associated `Error` value contains the original decoding error.
    case encodingError(Error)

    /// An error occurred during the execution of a request interceptor.
    case interceptorError(Error)

    /// An error occurred during the execution of a response interceptor.
    case responseInterceptorError(Error)

    /// An unexpected or unknown error occurred.
    case unknown(Error?)
}
