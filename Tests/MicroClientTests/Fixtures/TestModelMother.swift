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

// MARK: - NetworkClient Test Models

struct TestRequestModel: Encodable, Equatable {

    let id: Int
    let name: String
}

struct TestResponseModel: Codable, Equatable {

    let success: Bool
    let message: String
    let data: TestData?

    struct TestData: Codable, Equatable {

        let value: String
    }
}

// MARK: - NetworkRequest Test Models

struct NetworkRequestTestModel: Encodable, Equatable {

    let id: Int
    let name: String
}

struct NetworkRequestResponseModel: Decodable, Equatable {

    let success: Bool
    let message: String
}

// MARK: - Decoding Test Models

struct DecodingTestModel: Decodable, Equatable {

    let id: Int
    let message: String
}

struct CustomDecodingModel: Decodable, Equatable {

    let id: Int
    let customMessage: String
}

// MARK: - HTTP Body Test Models

struct HTTPBodyTestModel: Encodable, Equatable {

    let value: String
}

// MARK: - Response Test Models

struct ResponseTestModel: Decodable, Equatable {

    let id: Int
    let name: String
}

// MARK: - Complex Models

struct ComplexModel: Decodable, Equatable {

    let id: UUID
    let metadata: [String: String]
    let timestamps: [Date]
    let isActive: Bool

}

enum TestModelMother {

    static func makeTestRequestModel(
        id: Int = 123,
        name: String = "John Doe"
    ) -> TestRequestModel {
        TestRequestModel(
            id: id,
            name: name
        )
    }

    static func makeSuccessfulResponseModel(
        message: String = "Created successfully"
    ) -> TestResponseModel {
        TestResponseModel(
            success: true,
            message: message,
            data: TestResponseModel.TestData(value: "test")
        )
    }

    // MARK: - NetworkRequest Models

    static func makeNetworkRequestTestModel(
        id: Int = 1,
        name: String = "test"
    ) -> NetworkRequestTestModel {
        NetworkRequestTestModel(
            id: id,
            name: name
        )
    }

    // MARK: - Decoding Models

    static func makeDecodingTestModel(
        id: Int = 123,
        message: String = "success"
    ) -> DecodingTestModel {
        DecodingTestModel(
            id: id,
            message: message
        )
    }

    static func makeCustomDecodingModel(
        id: Int = 123,
        customMessage: String = "success"
    ) -> CustomDecodingModel {
        CustomDecodingModel(
            id: id,
            customMessage: customMessage
        )
    }

    // MARK: - HTTP Body Models

    static func makeHTTPBodyTestModel(
        value: String = "test"
    ) -> HTTPBodyTestModel {
        HTTPBodyTestModel(value: value)
    }

    // MARK: - Response Models

    static func makeResponseTestModel(
        id: Int = 123,
        name: String = "Test"
    ) -> ResponseTestModel {
        ResponseTestModel(
            id: id,
            name: name
        )
    }

    // MARK: - Complex Models

    static func makeComplexModel(
        id: UUID = UUID(),
        metadata: [String: String] = ["key1": "value1", "key2": "value2"],
        timestamps: [Date] = [Date(), Date().addingTimeInterval(-3600)],
        isActive: Bool = true
    ) -> ComplexModel {
        ComplexModel(
            id: id,
            metadata: metadata,
            timestamps: timestamps,
            isActive: isActive
        )
    }
}
