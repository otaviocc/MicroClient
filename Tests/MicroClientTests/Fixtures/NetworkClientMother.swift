import Foundation

@testable import MicroClient

// swiftlint:disable force_unwrapping

enum NetworkClientMother {

    static func makeNetworkClient(
        session: URLSessionProtocol = URLSessionMock(),
        baseURL: URL = URL(string: "https://api.example.com")!,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        retryStrategy: RetryStrategy = .none
    ) -> NetworkClient {
        let configuration = makeNetworkConfiguration(
            session: session,
            baseURL: baseURL,
            decoder: decoder,
            encoder: encoder,
            retryStrategy: retryStrategy
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
        interceptor: NetworkRequestsInterceptor? = nil,
        asyncInterceptor: NetworkAsyncRequestInterceptor? = nil
    ) -> NetworkConfiguration {
        NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            retryStrategy: retryStrategy,
            interceptor: interceptor,
            asyncInterceptor: asyncInterceptor
        )
    }
}

// swiftlint:enable force_unwrapping
