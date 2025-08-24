import Foundation
@testable import MicroClient

// MARK: - NetworkClient Mother

enum NetworkClientMother {

    // MARK: - NetworkClient

    static func makeNetworkClient(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!, // swiftlint:disable:this force_unwrapping
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) -> NetworkClient {
        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        return NetworkClient(configuration: configuration)
    }

    // MARK: - URLSessionMock

    static func makeMockSession() -> URLSessionMock {
        URLSessionMock()
    }

    // MARK: - HTTPURLResponse

    static func makeSuccessResponse(
        for url: URL,
        statusCode: Int = 200,
        httpVersion: String = "HTTP/1.1",
        headerFields: [String: String]? = ["Content-Type": "application/json"]
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
        )! // swiftlint:disable:this force_unwrapping
    }

    static func makeErrorResponse(
        for url: URL,
        statusCode: Int = 500,
        httpVersion: String = "HTTP/1.1",
        headerFields: [String: String]? = ["Content-Type": "application/json"]
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
        )! // swiftlint:disable:this force_unwrapping
    }

    static func makeNotFoundResponse(
        for url: URL,
        httpVersion: String = "HTTP/1.1",
        headerFields: [String: String]? = ["Content-Type": "application/json"]
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: httpVersion,
            headerFields: headerFields
        )! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - NetworkConfiguration

    static func makeNetworkConfiguration(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!, // swiftlint:disable:this force_unwrapping
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        interceptor: ((URLRequest) -> URLRequest)? = nil
    ) -> NetworkConfiguration {
        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        configuration.interceptor = interceptor

        return configuration
    }
}
