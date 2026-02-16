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

@Suite("NetworkRequest Encoding Tests")
struct NetworkRequestEncodingTests {

    @Test("It should encode model using default encoder")
    func encodeModelUsingDefaultEncoder() throws {
        let testModel = TestModelMother.makeNetworkRequestTestModel()
        let request = NetworkRequest<NetworkRequestTestModel, VoidResponse>(method: .post)
        let defaultEncoder = JSONEncoder()
        let encodedData = try request.encode(
            payload: testModel,
            defaultEncoder: defaultEncoder
        )

        #expect(
            !encodedData.isEmpty,
            "It should return encoded data"
        )

        let jsonString = String(data: encodedData, encoding: .utf8)
        #expect(
            jsonString?.contains("test") == true,
            "It should contain encoded model data"
        )
    }

    @Test("It should encode model using custom encoder")
    func encodeModelUsingCustomEncoder() throws {
        let testModel = TestModelMother.makeNetworkRequestTestModel()

        let customEncoder = JSONEncoder()
        customEncoder.keyEncodingStrategy = .convertToSnakeCase

        let request = NetworkRequest<NetworkRequestTestModel, VoidResponse>(
            method: .post,
            encoder: customEncoder
        )

        let defaultEncoder = JSONEncoder()
        let encodedData = try request.encode(
            payload: testModel,
            defaultEncoder: defaultEncoder
        )

        #expect(
            !encodedData.isEmpty,
            "It should return encoded data with custom encoder"
        )
    }

    @Test("It should return Data directly when payload is Data")
    func returnDataDirectlyWhenPayloadIsData() throws {
        let originalData = Data("raw data".utf8)
        let request = NetworkRequest<Data, VoidResponse>(method: .post)
        let defaultEncoder = JSONEncoder()
        let encodedData = try request.encode(
            payload: originalData,
            defaultEncoder: defaultEncoder
        )

        #expect(
            encodedData == originalData,
            "It should return the same Data when payload is already Data"
        )
    }
}
