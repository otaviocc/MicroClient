import Testing
import Foundation
import Combine

@testable import MicroClient

@Suite("NetworkClient Tests")
struct NetworkClientTests {

    @Test("It should perform successful GET request with VoidResponse")
    func performSuccessfulGETRequestWithVoidResponse() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/ping"))
        mockSession.dataToReturn = Data()
        mockSession.responseToReturn = NetworkClientMother.makeSuccessResponse(
            for: expectedURL
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/ping",
            method: .get
        )

        let response = try await client.run(request)

        #expect(
            response.value != nil,
            "It should return VoidResponse"
        )
        #expect(
            mockSession.lastRequest?.httpMethod == "GET",
            "It should use GET method"
        )
        #expect(
            mockSession.lastRequest?.url?.absoluteString.hasPrefix("https://api.example.com/ping") == true,
            "It should construct correct URL"
        )
    }

    @Test("It should perform successful POST request with JSON body")
    func performSuccessfulPOSTRequestWithJSONBody() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let responseData = Data("""
        {"success": true, "message": "Created successfully", "data": {"value": "test"}}
        """.utf8)

        let expectedURL = try #require(URL(string: "https://api.example.com/users"))
        mockSession.dataToReturn = responseData
        mockSession.responseToReturn = NetworkClientMother.makeSuccessResponse(
            for: expectedURL,
            statusCode: 201
        )

        let requestBody = TestModelMother.makeTestRequestModel()
        let request = NetworkRequest<TestRequestModel, TestResponseModel>(
            path: "/users",
            method: .post,
            body: requestBody
        )

        let response = try await client.run(request)

        let expectedResponse = TestModelMother.makeSuccessfulResponseModel()

        #expect(
            response.value == expectedResponse,
            "It should decode response correctly"
        )
        #expect(
            mockSession.lastRequest?.httpMethod == "POST",
            "It should use POST method"
        )
        #expect(
            mockSession.lastRequest?.httpBody != nil,
            "It should include request body"
        )
    }

    @Test("It should handle network errors")
    func handleNetworkErrors() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let networkError = URLError(.notConnectedToInternet)
        mockSession.errorToThrow = networkError

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        do {
            _ = try await client.run(request)
            #expect(Bool(false), "It should throw network error")
        } catch {
            #expect(
                error is URLError,
                "It should propagate URLError"
            )
        }
    }

    @Test("It should use custom headers")
    func useCustomHeaders() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/protected"))
        mockSession.dataToReturn = Data()
        mockSession.responseToReturn = NetworkClientMother.makeSuccessResponse(
            for: expectedURL
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/protected",
            method: .get,
            additionalHeaders: [
                "Authorization": "Bearer token123",
                "X-Custom-Header": "custom-value"
            ]
        )

        _ = try await client.run(request)

        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer token123",
            "It should set Authorization header"
        )
        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "X-Custom-Header") == "custom-value",
            "It should set custom header"
        )
    }

    @Test("It should handle query parameters")
    func handleQueryParameters() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/search?q=swift&limit=10"))
        mockSession.dataToReturn = Data()
        mockSession.responseToReturn = NetworkClientMother.makeSuccessResponse(
            for: expectedURL
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/search",
            method: .get,
            queryItems: [
                URLQueryItem(name: "q", value: "swift"),
                URLQueryItem(name: "limit", value: "10")
            ]
        )

        _ = try await client.run(request)

        let actualURL = mockSession.lastRequest?.url?.absoluteString
        #expect(
            actualURL?.contains("q=swift") == true,
            "It should include query parameter q"
        )
        #expect(
            actualURL?.contains("limit=10") == true,
            "It should include query parameter limit"
        )
    }

    @Test("It should use interceptor when configured")
    func useInterceptorWhenConfigured() async throws {
        let mockSession = NetworkClientMother.makeMockSession()

        // Configure interceptor to add authentication
        let interceptor: (URLRequest) -> URLRequest = { request in
            var modifiedRequest = request
            modifiedRequest.setValue(
                "Bearer intercepted-token",
                forHTTPHeaderField: "Authorization"
            )
            return modifiedRequest
        }

        let configuration = NetworkClientMother.makeNetworkConfiguration(
            session: mockSession,
            interceptor: interceptor
        )
        let client = NetworkClient(configuration: configuration)

        let expectedURL = try #require(URL(string: "https://api.example.com/data"))
        mockSession.dataToReturn = Data()
        mockSession.responseToReturn = NetworkClientMother.makeSuccessResponse(
            for: expectedURL
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/data",
            method: .get
        )

        _ = try await client.run(request)

        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer intercepted-token",
            "It should apply interceptor modifications"
        )
    }
}
