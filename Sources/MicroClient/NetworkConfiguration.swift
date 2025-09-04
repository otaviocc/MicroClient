import Foundation

/// The network client configuration.
public struct NetworkConfiguration: Sendable {

    /// The session used to perform the network requests.
    public let session: URLSessionProtocol

    /// The default JSON decoder. It can be overwritten by
    /// individual requests, if necessary.
    public let defaultDecoder: JSONDecoder

    /// The default JSON encoder. It can be overwritten by
    /// individual requests, if necessary.
    public let defaultEncoder: JSONEncoder

    /// The base URL component.
    /// E.g., `https://hostname.com/api/v3`
    public let baseURL: URL

    /// The retry strategy for network requests. The default
    /// value is `.none`.
    public let retryStrategy: RetryStrategy

    /// The logger used for logging network requests and responses.
    /// If `nil`, no logging will be performed.
    public let logger: NetworkLogger?

    /// The log level for the logger. The default value is `.info`.
    public let logLevel: NetworkLogLevel

    /// A chain of interceptors that can inspect and modify requests before they are sent.
    /// Interceptors are applied in the order they appear in this array.
    public let interceptors: [NetworkRequestInterceptor]

    /// Initializes the network client configuration.
    /// - Parameters:
    ///   - session: The session used to perform the network requests.
    ///   - defaultDecoder: The default JSON decoder.
    ///   - defaultEncoder: The default JSON encoder.
    ///   - baseURL: The base URL component.
    ///   - retryStrategy: The retry strategy for network requests.
    ///   - logger: The logger for network requests and responses.
    ///   - logLevel: The log level for the logger.
    ///   - interceptors: A chain of interceptors to apply to requests. Defaults to an empty array.
    public init(
        session: URLSessionProtocol,
        defaultDecoder: JSONDecoder,
        defaultEncoder: JSONEncoder,
        baseURL: URL,
        retryStrategy: RetryStrategy = .none,
        logger: NetworkLogger? = nil,
        logLevel: NetworkLogLevel = .info,
        interceptors: [NetworkRequestInterceptor] = []
    ) {
        self.session = session
        self.defaultDecoder = defaultDecoder
        self.defaultEncoder = defaultEncoder
        self.baseURL = baseURL
        self.retryStrategy = retryStrategy
        self.logger = logger
        self.logLevel = logLevel
        self.interceptors = interceptors
    }
}
