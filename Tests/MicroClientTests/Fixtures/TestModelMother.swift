import Foundation

@testable import MicroClient

// MARK: - NetworkClient Test Models

struct TestRequestModel: Encodable, Equatable {
    let id: Int
    let name: String
}

struct TestResponseModel: Decodable, Equatable {
    let success: Bool
    let message: String
    let data: TestData?

    struct TestData: Decodable, Equatable {
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

    static func == (
        lhs: ComplexModel,
        rhs: ComplexModel
    ) -> Bool {
        lhs.id == rhs.id &&
               lhs.metadata == rhs.metadata &&
               lhs.timestamps == rhs.timestamps &&
               lhs.isActive == rhs.isActive
    }
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
