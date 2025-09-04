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
        let retryStrategy = networkRequest.retryStrategy ?? configuration.retryStrategy
        var lastError: Error?

        for attempt in 0...retryStrategy.count {
            do {
                return try await performRequest(networkRequest, attempt: attempt)
            } catch {
                lastError = error
            }
        }

        throw lastError ?? NetworkClientError.unknown
    }

    // MARK: - Private

    private func performRequest<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>,
        attempt: Int
    ) async throws -> NetworkResponse<ResponseModel> {
        if attempt > 0 {
            log(.warning, "Retrying request... Attempt \(attempt)")
        }

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

        log(.info, "Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        log(.debug, "Headers: \(request.allHTTPHeaderFields ?? [:])")

        do {
            let (data, response) = try await configuration.session.data(
                for: request,
                delegate: nil
            )

            if let httpResponse = response as? HTTPURLResponse {
                log(.info, "Response: \(httpResponse.statusCode)")
                log(.debug, "Response headers: \(httpResponse.allHeaderFields)")
            }

            let value = try networkRequest.decode(
                data: data,
                defaultDecoder: configuration.defaultDecoder
            )

            log(.debug, "Response data: \(String(data: data, encoding: .utf8) ?? "")")

            return NetworkResponse(
                value: value,
                response: response
            )
        } catch {
            log(.error, "Error: \(error.localizedDescription)")
            throw error
        }
    }

    private func log(_ level: NetworkLogLevel, _ message: String) {
        guard let logger = configuration.logger,
              level >= configuration.logLevel else { return }

        logger.log(level: level, message: message)
    }
}
