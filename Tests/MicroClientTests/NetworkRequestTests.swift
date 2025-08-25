import Testing
import Foundation

@testable import MicroClient

@Suite("NetworkRequest Tests")
struct NetworkRequestTests {

    // swiftlint:disable function_body_length
    @Test("It should initialize with all parameters")
    func initializeWithAllParameters() throws {
        let path = "/api/test"
        let method: HTTPMethod = .post
        let queryItems = [URLQueryItem(name: "param", value: "value")]
        let formItems = [URLFormItem(name: "field", value: "data")]
        let body = TestModelMother.makeNetworkRequestTestModel()
        let baseURL = try #require(URL(string: "https://api.example.com"))
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let additionalHeaders = ["Authorization": "Bearer token"]

        let request = NetworkRequest<NetworkRequestTestModel, NetworkRequestResponseModel>(
            path: path,
            method: method,
            queryItems: queryItems,
            formItems: formItems,
            body: body,
            baseURL: baseURL,
            decoder: decoder,
            encoder: encoder,
            additionalHeaders: additionalHeaders
        )

        #expect(
            request.path == path,
            "It should store the provided path"
        )
        #expect(
            request.method == method,
            "It should store the provided method"
        )
        #expect(
            request.queryItems == queryItems,
            "It should store the provided query items"
        )
        #expect(
            request.formItems == formItems,
            "It should store the provided form items"
        )
        #expect(
            request.body == body,
            "It should store the provided body"
        )
        #expect(
            request.baseURL == baseURL,
            "It should store the provided base URL"
        )
        #expect(
            request.decoder === decoder,
            "It should store the provided decoder"
        )
        #expect(
            request.encoder === encoder,
            "It should store the provided encoder"
        )
        #expect(
            request.additionalHeaders == additionalHeaders,
            "It should store the provided additional headers"
        )
    }
    // swiftlint:enable function_body_length

    @Test("It should initialize with minimal required parameters")
    func initializeWithMinimalParameters() {
        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get
        )

        #expect(
            request.path == nil,
            "It should have nil path as default"
        )
        #expect(
            request.method == .get,
            "It should store the provided method"
        )
        #expect(
            request.queryItems.isEmpty,
            "It should have empty query items as default"
        )
        #expect(
            request.formItems == nil,
            "It should have nil form items as default"
        )
        #expect(
            request.body == nil,
            "It should have nil body as default"
        )
        #expect(
            request.baseURL == nil,
            "It should have nil base URL as default"
        )
        #expect(
            request.decoder == nil,
            "It should have nil decoder as default"
        )
        #expect(
            request.encoder == nil,
            "It should have nil encoder as default"
        )
        #expect(
            request.additionalHeaders == nil,
            "It should have nil additional headers as default"
        )
    }

    @Test("It should support different HTTP methods")
    func supportDifferentHTTPMethods() {
        let getRequest = NetworkRequest<VoidRequest, VoidResponse>(method: .get)
        let postRequest = NetworkRequest<VoidRequest, VoidResponse>(method: .post)
        let deleteRequest = NetworkRequest<VoidRequest, VoidResponse>(method: .delete)
        let putRequest = NetworkRequest<VoidRequest, VoidResponse>(method: .put)
        let patchRequest = NetworkRequest<VoidRequest, VoidResponse>(method: .patch)

        #expect(
            getRequest.method == .get,
            "It should support GET method"
        )
        #expect(
            postRequest.method == .post,
            "It should support POST method"
        )
        #expect(
            deleteRequest.method == .delete,
            "It should support DELETE method"
        )
        #expect(
            putRequest.method == .put,
            "It should support PUT method"
        )
        #expect(
            patchRequest.method == .patch,
            "It should support PATCH method"
        )
    }

    @Test("It should work with VoidRequest and VoidResponse")
    func workWithVoidTypes() {
        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/api/ping",
            method: .get
        )

        #expect(
            request.path == "/api/ping",
            "It should store the path with VoidRequest/VoidResponse"
        )
        #expect(
            request.method == .get,
            "It should store the method with VoidRequest/VoidResponse"
        )
        #expect(
            request.body == nil,
            "It should have nil body with VoidRequest"
        )
    }
}
