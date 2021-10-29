import Foundation

public protocol NetworkClientProtocol {

    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
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
    ) async throws -> NetworkResponse<ResponseModel>  {
        var request = try URLRequest.makeURLRequest(
            configuration: configuration,
            networkRequest: networkRequest
        )

        if let interceptor = configuration.interceptor {
            request = interceptor(request)
        }

        let (data, response) = try await configuration.session.data(
            for: request
        )

        return NetworkResponse(
            value: try networkRequest.decode(
                data: data,
                defaultDecoder: configuration.defaultDecoder
            ),
            response: response
        )
    }
}
