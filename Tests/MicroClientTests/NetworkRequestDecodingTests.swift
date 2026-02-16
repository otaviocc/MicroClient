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

@Suite("NetworkRequest Decoding Tests")
struct NetworkRequestDecodingTests {

    @Test("It should decode data using default decoder")
    func decodeDataUsingDefaultDecoder() throws {
        let jsonData = Data("""
        {"id": 123, "message": "success"}
        """.utf8)

        let request = NetworkRequest<VoidRequest, DecodingTestModel>(method: .get)
        let defaultDecoder = JSONDecoder()
        let decodedModel = try request.decode(
            data: jsonData,
            defaultDecoder: defaultDecoder
        )

        let expectedModel = TestModelMother.makeDecodingTestModel()
        #expect(
            decodedModel == expectedModel,
            "It should decode data correctly using default decoder"
        )
    }

    @Test("It should decode data using custom decoder")
    func decodeDataUsingCustomDecoder() throws {
        let jsonData = Data("""
        {"id": 123, "custom_message": "success"}
        """.utf8)

        let customDecoder = JSONDecoder()
        customDecoder.keyDecodingStrategy = .convertFromSnakeCase

        let request = NetworkRequest<VoidRequest, CustomDecodingModel>(
            method: .get,
            decoder: customDecoder
        )

        let defaultDecoder = JSONDecoder()
        let decodedModel = try request.decode(
            data: jsonData,
            defaultDecoder: defaultDecoder
        )

        let expectedModel = TestModelMother.makeCustomDecodingModel()
        #expect(
            decodedModel == expectedModel,
            "It should decode data correctly using custom decoder"
        )
    }

    @Test("It should return VoidResponse when ResponseModel is VoidResponse")
    func returnVoidResponseWhenResponseModelIsVoidResponse() throws {
        let jsonData = Data("""
        {"some": "data"}
        """.utf8)

        let request = NetworkRequest<VoidRequest, VoidResponse>(method: .get)
        let defaultDecoder = JSONDecoder()
        let decodedModel = try request.decode(
            data: jsonData,
            defaultDecoder: defaultDecoder
        )

        #expect(
            type(of: decodedModel) == VoidResponse.self,
            "It should return VoidResponse instance when ResponseModel is VoidResponse"
        )
    }

    @Test("It should handle empty data for VoidResponse")
    func handleEmptyDataForVoidResponse() throws {
        let emptyData = Data()
        let request = NetworkRequest<VoidRequest, VoidResponse>(method: .get)
        let defaultDecoder = JSONDecoder()
        let decodedModel = try request.decode(
            data: emptyData,
            defaultDecoder: defaultDecoder
        )

        #expect(
            type(of: decodedModel) == VoidResponse.self,
            "It should handle empty data for VoidResponse"
        )
    }
}
