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

/// A single name-value pair from the form portion of a request.
public struct URLFormItem: Sendable {

    // MARK: - Properties

    /// The name of the form item.
    public let name: String

    /// The value for the form item.
    public let value: String?

    // MARK: - Life cycle

    /// Initializes a form item.
    /// - Parameters:
    ///   - name: The name of the form item.
    ///   - value: The value of the form item.
    public init(
        name: String,
        value: String?
    ) {
        self.name = name
        self.value = value
    }
}

// MARK: - Extensions

extension URLFormItem: Equatable {}
extension URLFormItem: Hashable {}

// MARK: - Array Extension

extension [URLFormItem] {

    func urlEncoded() -> Data? {
        var components = URLComponents()

        components.queryItems = map {
            .init(
                name: $0.name,
                value: $0.value
            )
        }
        .filter { $0.value != nil }

        return components
            .percentEncodedQuery?
            .data(
                using: .utf8
            )
    }
}
