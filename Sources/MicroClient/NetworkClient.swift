import Foundation

/// The network client interface.
public protocol NetworkClientProtocol {

    /// Initializes the client with a given configuration.
    /// - Parameter configuration: The client configuration.
    init(
        configuration: NetworkConfiguration
    )

    /// Performs the network request.
    ///
    /// - Parameter networkRequest: The network request to perform.
    /// - Returns: The network response.
    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
}

/// The network client, conforming to the `NetworkClientProtocol` protocol.
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
    ) async throws -> NetworkResponse<ResponseModel> {
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
