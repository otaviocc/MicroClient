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
@testable import MicroClient

final class URLSessionMock: URLSessionProtocol, @unchecked Sendable {

    // MARK: - Properties

    private(set) var lastRequest: URLRequest?
    private(set) var requestCount = 0
    private var stubbedDataToReturn = Data()
    private var stubbedResponseToReturn = URLResponse()
    private var stubbedErrorToThrow: Error?
    var succeedAfter = 0
    var delay: TimeInterval = 0

    // MARK: - Public

    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        lastRequest = request
        requestCount += 1

        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        if succeedAfter > 0, requestCount > succeedAfter {
            // Do not throw error, return stubbed data
        } else if let error = stubbedErrorToThrow {
            throw error
        }

        return (stubbedDataToReturn, stubbedResponseToReturn)
    }
}

// MARK: - Stub

extension URLSessionMock {

    func stubDataToReturn(
        data: Data,
        response: URLResponse
    ) {
        stubbedDataToReturn = data
        stubbedResponseToReturn = response
    }

    func stubDataToThrow(error: Error?) {
        stubbedErrorToThrow = error
    }
}
