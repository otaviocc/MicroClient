import Foundation

@testable import MicroClient

// swiftlint:disable force_unwrapping

enum NetworkClientMother {

    static func makeNetworkClient(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        retryStrategy: RetryStrategy = .none,
        logger: NetworkLogger? = nil,
        logLevel: NetworkLogLevel = .info
    ) -> NetworkClient {
        let configuration = makeNetworkConfiguration(
            session: session,
            baseURL: baseURL,
            decoder: decoder,
            encoder: encoder,
            retryStrategy: retryStrategy,
            logger: logger,
            logLevel: logLevel
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

    static func makeNetworkConfiguration(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        retryStrategy: RetryStrategy = .none,
        logger: NetworkLogger? = nil,
        logLevel: NetworkLogLevel = .info,
        interceptors: [NetworkRequestInterceptor] = []
    ) -> NetworkConfiguration {
        NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            retryStrategy: retryStrategy,
            logger: logger,
            logLevel: logLevel,
            interceptors: interceptors
        )
    }
}

// swiftlint:enable force_unwrapping
