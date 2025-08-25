import Testing
import Foundation

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
