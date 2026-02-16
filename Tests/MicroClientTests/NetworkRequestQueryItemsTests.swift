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
import Testing
@testable import MicroClient

@Suite("NetworkRequest Query Items Tests")
struct NetworkRequestQueryItemsTests {

    @Test("It should store multiple query items")
    func storeMultipleQueryItems() {
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "sort", value: "name")
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get,
            queryItems: queryItems
        )

        #expect(
            request.queryItems.count == 3,
            "It should store all query items"
        )
        #expect(
            request.queryItems == queryItems,
            "It should store the exact query items"
        )
    }

    @Test("It should handle query items with nil values")
    func handleQueryItemsWithNilValues() {
        let queryItems = [
            URLQueryItem(name: "required", value: "value"),
            URLQueryItem(name: "optional", value: nil)
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get,
            queryItems: queryItems
        )

        #expect(
            request.queryItems.count == 2,
            "It should store all query items including ones with nil values"
        )
        #expect(
            request.queryItems[1].value == nil,
            "It should preserve nil values in query items"
        )
    }

    @Test("It should not add a trailing '?' when there are no query items")
    func noTrailingQuestionMark() throws {
        let configuration = NetworkClientMother.makeNetworkConfiguration()

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/v1/endpoint",
            method: .get
        )

        let url = try URL.makeURL(
            configuration: configuration,
            networkRequest: request
        )

        #expect(
            url.absoluteString == "https://api.example.com/v1/endpoint",
            "It should not have a trailing '?'"
        )
    }

    @Test("It should add a trailing '?' when an empty queryItems is provided")
    func trailingQuestionMarkWithEmptyQueryItems() throws {
        let configuration = NetworkClientMother.makeNetworkConfiguration()

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/v1/endpoint",
            method: .get,
            queryItems: []
        )

        let url = try URL.makeURL(
            configuration: configuration,
            networkRequest: request
        )

        #expect(
            url.absoluteString == "https://api.example.com/v1/endpoint",
            "It should not have a trailing '?'"
        )
    }

    @Test("It should add '?' and query items when query items are present")
    func addQuestionMarkWithQueryItems() throws {
        let configuration = NetworkClientMother.makeNetworkConfiguration()

        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "sort", value: "name")
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/v1/endpoint",
            method: .get,
            queryItems: queryItems
        )

        let url = try URL.makeURL(
            configuration: configuration,
            networkRequest: request
        )

        #expect(
            url.absoluteString == "https://api.example.com/v1/endpoint?page=1&limit=10&sort=name",
            "It should add the '?' and query items"
        )
    }
}
