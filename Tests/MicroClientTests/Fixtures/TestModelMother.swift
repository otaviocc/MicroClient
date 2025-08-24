import Foundation

@testable import MicroClient

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

    static func makeTestResponseModel(
        success: Bool = true,
        message: String = "Success",
        data: TestResponseModel.TestData? = makeTestData()
    ) -> TestResponseModel {
        TestResponseModel(
            success: success,
            message: message,
            data: data
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

    static func makeFailedResponseModel(
        message: String = "Operation failed"
    ) -> TestResponseModel {
        TestResponseModel(
            success: false,
            message: message,
            data: nil
        )
    }

    static func makeTestData(
        value: String = "test"
    ) -> TestResponseModel.TestData {
        TestResponseModel.TestData(value: value)
    }
}
