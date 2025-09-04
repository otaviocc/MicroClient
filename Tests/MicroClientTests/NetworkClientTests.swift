import Testing
import Foundation

@testable import MicroClient

// swiftlint:disable type_body_length

@Suite("NetworkClient Tests")
struct NetworkClientTests {

    @Test("It should perform successful GET request with VoidResponse")
    func performSuccessfulGETRequestWithVoidResponse() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/ping"))

        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL
            )
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/ping",
            method: .get
        )

        let response = try await client.run(request)

        #expect(
            type(of: response.value) == VoidResponse.self,
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
        mockSession.stubDataToReturn(
            data: responseData,
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL,
                statusCode: 201
            )
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
        mockSession.stubDataToThrow(error: networkError)

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        await #expect(throws: NetworkClientError.self) {
            _ = try await client.run(request)
        }
    }

    @Test("It should use custom headers")
    func useCustomHeaders() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        let expectedURL = try #require(URL(string: "https://api.example.com/protected"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL
            )
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
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(
                for: expectedURL
            )
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
        let storage = MockInterceptorStorage()
        let interceptor = HeaderInterceptor(
            headerName: "X-Test",
            headerValue: "success",
            storage: storage
        )

        let configuration = NetworkClientMother.makeNetworkConfiguration(
            session: mockSession,
            interceptors: [interceptor]
        )
        let client = NetworkClient(configuration: configuration)

        let expectedURL = try #require(URL(string: "https://api.example.com/data"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(path: "/data", method: .get)
        _ = try await client.run(request)

        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "X-Test") == "success",
            "It should apply the interceptor modification"
        )
        let callOrder = await storage.callOrder
        #expect(
            callOrder == ["X-Test"],
            "It should call the interceptor"
        )
    }

    @Test("It should apply interceptors in order")
    func applyInterceptorsInOrder() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let storage = MockInterceptorStorage()
        let interceptor1 = HeaderInterceptor(
            headerName: "X-First",
            headerValue: "1",
            storage: storage
        )
        let interceptor2 = HeaderInterceptor(
            headerName: "X-Second",
            headerValue: "2",
            storage: storage
        )

        let configuration = NetworkClientMother.makeNetworkConfiguration(
            session: mockSession,
            interceptors: [interceptor1, interceptor2]
        )
        let client = NetworkClient(configuration: configuration)

        let expectedURL = try #require(URL(string: "https://api.example.com/data"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(path: "/data", method: .get)
        _ = try await client.run(request)

        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "X-First") == "1",
            "It should apply the first interceptor"
        )
        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "X-Second") == "2",
            "It should apply the second interceptor"
        )
        let callOrder = await storage.callOrder
        #expect(
            callOrder == ["X-First", "X-Second"],
            "It should call the interceptors in the correct order"
        )
    }

    @Test("It should prioritize per-request interceptors")
    func prioritizePerRequestInterceptors() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let globalStorage = MockInterceptorStorage()
        let requestStorage = MockInterceptorStorage()

        let globalInterceptor = HeaderInterceptor(
            headerName: "X-Global",
            headerValue: "global",
            storage: globalStorage
        )
        let requestInterceptor = HeaderInterceptor(
            headerName: "X-Request",
            headerValue: "request",
            storage: requestStorage
        )

        let configuration = NetworkClientMother.makeNetworkConfiguration(
            session: mockSession,
            interceptors: [globalInterceptor]
        )
        let client = NetworkClient(configuration: configuration)

        let expectedURL = try #require(URL(string: "https://api.example.com/data"))
        mockSession.stubDataToReturn(
            data: Data(),
            response: NetworkClientMother.makeSuccessResponse(for: expectedURL)
        )

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/data",
            method: .get,
            interceptors: [requestInterceptor]
        )
        _ = try await client.run(request)

        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "X-Global") == nil,
            "It should not apply the global interceptor"
        )
        #expect(
            mockSession.lastRequest?.value(forHTTPHeaderField: "X-Request") == "request",
            "It should apply the per-request interceptor"
        )

        let globalCalls = await globalStorage.callOrder
        let requestCalls = await requestStorage.callOrder
        #expect(
            globalCalls.isEmpty,
            "It should not call the global interceptor"
        )
        #expect(
            requestCalls == ["X-Request"],
            "It should call the per-request interceptor"
        )
    }

    @Test("It should handle interceptor errors")
    func handleInterceptorErrors() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let throwingInterceptor = ThrowingInterceptor()

        let configuration = NetworkClientMother.makeNetworkConfiguration(
            session: mockSession,
            interceptors: [throwingInterceptor]
        )
        let client = NetworkClient(configuration: configuration)
        let request = NetworkRequest<VoidRequest, VoidResponse>(path: "/test", method: .get)

        await #expect(throws: NetworkClientError.self) {
            _ = try await client.run(request)
        }
    }
}

// swiftlint:enable type_body_length
