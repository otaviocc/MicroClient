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
