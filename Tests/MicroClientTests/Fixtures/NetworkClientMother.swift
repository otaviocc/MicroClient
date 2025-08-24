import Foundation

@testable import MicroClient

// swiftlint:disable force_unwrapping

enum NetworkClientMother {

    static func makeNetworkClient(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!,
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

    static func makeMockSession() -> URLSessionMock {
        URLSessionMock()
    }

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
        )!
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
        )!
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
        )!
    }

    static func makeNetworkConfiguration(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!,
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

// swiftlint:enable force_unwrapping
