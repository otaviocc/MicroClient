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
import Testing
@testable import MicroClient

@Suite("NetworkResponse with Complex Models Tests")
struct NetworkResponseComplexModelsTests {

    @Test("It should work with complex nested models")
    func workWithComplexNestedModels() throws {
        let complexModel = TestModelMother.makeComplexModel()

        let url = try #require(URL(string: "https://api.example.com/complex"))
        let httpResponse = try #require(HTTPURLResponse(
            url: url,
            statusCode: 201,
            httpVersion: "HTTP/2.0",
            headerFields: [
                "Content-Type": "application/json",
                "Location": "/api/complex/\(complexModel.id)"
            ]
        ))

        let networkResponse = NetworkResponse(
            value: complexModel,
            response: httpResponse
        )

        #expect(
            networkResponse.value == complexModel,
            "It should store the complex model"
        )
        #expect(
            networkResponse.response === httpResponse,
            "It should store the HTTPURLResponse"
        )
        if let httpUrlResponse = networkResponse.response as? HTTPURLResponse {
            #expect(
                httpUrlResponse.statusCode == 201,
                "It should preserve HTTP status code for complex models"
            )
            #expect(
                httpUrlResponse.allHeaderFields["Location"] as? String == "/api/complex/\(complexModel.id)",
                "It should preserve HTTP headers for complex models"
            )
            #expect(
                httpResponse.location?.absoluteString == "/api/complex/\(complexModel.id)",
                "It should preserve HTTP headers for complex models"
            )
        }
    }
}
