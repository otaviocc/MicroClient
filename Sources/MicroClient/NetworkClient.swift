import Combine
import Foundation

public protocol NetworkClientProtocol {

    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) -> AnyPublisher<NetworkResponse<ResponseModel>, Error>
}

public final class NetworkClient: NetworkClientProtocol {

    // MARK: - Properties

    private let configuration: NetworkConfiguration

    // MARK: - Life cycle

    public init(
        configuration: NetworkConfiguration
    ) {
        self.configuration = configuration
    }

    // MARK: - Public

    public func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) -> AnyPublisher<NetworkResponse<ResponseModel>, Error> {
        urlRequestPublisher(networkRequest: networkRequest)
            .flatMap { request in
                self.requestPublisher(
                    urlRequest: request,
                    networkRequest: networkRequest
                )
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func urlRequestPublisher<RequestModel, ResponseModel>(
        networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) -> AnyPublisher<URLRequest, Error> {
        Result {
            try URLRequest.makeURLRequest(
                configuration: configuration,
                networkRequest: networkRequest
            )
        }
        .publisher
        .unwrap(with: NetworkClientError.malformedURLRequest)
        .compactMap { [configuration] request in
            configuration.interceptor?(request)
        }
        .eraseToAnyPublisher()
    }

    private func requestPublisher<RequestModel, ResponseModel>(
        urlRequest: URLRequest,
        networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) -> AnyPublisher<NetworkResponse<ResponseModel>, Error> {
        configuration.session
            .dataTaskPublisher(for: urlRequest)
            .tryMap { [configuration] result in
                NetworkResponse(
                    value: try networkRequest.decode(
                        data: result.data,
                        defaultDecoder: configuration.defaultDecoder
                    ),
                    response: result.response
                )
            }
            .eraseToAnyPublisher()
    }
}
