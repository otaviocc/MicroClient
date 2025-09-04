import Testing
import Foundation
import Combine

@testable import MicroClient

@Suite("NetworkClient Error Handling Tests")
struct NetworkClientErrorHandlingTests {

    @Test("It should handle JSON decoding errors")
    func handleJSONDecodingErrors() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )
        let invalidJSON = Data("{ invalid json".utf8)
        let expectedURL = try #require(URL(string: "https://api.example.com/data"))

        let response = try #require(
            HTTPURLResponse(
                url: expectedURL,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
        )
        mockSession.stubDataToReturn(
            data: invalidJSON,
            response: response
        )

        let request = NetworkRequest<VoidRequest, TestResponseModel>(
            path: "/data",
            method: .get
        )

        await #expect(throws: NetworkClientError.self) {
            _ = try await client.run(request)
        }
    }

    @Test("It should handle unacceptable status codes")
    func handleUnacceptableStatusCodes() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(session: mockSession)
        let errorData = Data("{\"error\": \"Not Found\"}".utf8)
        let expectedURL = try #require(URL(string: "https://api.example.com/notfound"))

        let response = try #require(
            HTTPURLResponse(
                url: expectedURL,
                statusCode: 404,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )
        )
        mockSession.stubDataToReturn(
            data: errorData,
            response: response
        )

        let request = NetworkRequest<VoidRequest, TestResponseModel>(
            path: "/notfound",
            method: .get
        )

        await #expect(throws: NetworkClientError.self) {
            _ = try await client.run(request)
        }
    }
}
