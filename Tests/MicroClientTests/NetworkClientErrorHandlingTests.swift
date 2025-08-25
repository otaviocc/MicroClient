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

        mockSession.dataToReturn = invalidJSON
        mockSession.responseToReturn = try #require(
            HTTPURLResponse(
                url: expectedURL,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
        )

        let request = NetworkRequest<VoidRequest, TestResponseModel>(
            path: "/data",
            method: .get
        )

        do {
            _ = try await client.run(request)
            #expect(Bool(false), "It should throw JSON decoding error")
        } catch {
            #expect(
                error is DecodingError,
                "It should throw DecodingError for invalid JSON"
            )
        }
    }
}
