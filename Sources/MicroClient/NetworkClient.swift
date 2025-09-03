import Foundation

/// The network client interface.
public protocol NetworkClientProtocol: Sendable {

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
public actor NetworkClient: NetworkClientProtocol {

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
        let retryCount = retries(for: networkRequest)
        var lastError: Error?

        for _ in 0...retryCount {
            do {
                return try await performRequest(networkRequest)
            } catch {
                lastError = error
            }
        }

        throw lastError ?? NetworkClientError.unknown
    }

    // MARK: - Private

    private func performRequest<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel> {
        var request = try URLRequest.makeURLRequest(
            configuration: configuration,
            networkRequest: networkRequest
        )

        if let interceptor = configuration.interceptor {
            request = interceptor(request)
        }

        if let asyncInterceptor = configuration.asyncInterceptor {
            request = await asyncInterceptor(request)
        }

        let (data, response) = try await configuration.session.data(
            for: request,
            delegate: nil
        )

        return NetworkResponse(
            value: try networkRequest.decode(
                data: data,
                defaultDecoder: configuration.defaultDecoder
            ),
            response: response
        )
    }

    private func retries<RequestModel, ResponseModel>(
        for networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) -> Int {
        let retryStrategy = networkRequest.retryStrategy ?? configuration.retryStrategy

        return switch retryStrategy {
        case .none: 0
        case .retry(let count): count
        }
    }
}
