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

    /// The interceptor called right before performing the
    /// network request. Can be used to modify the `URLRequest`
    /// if necessary.
    public let interceptor: (@Sendable (URLRequest) -> URLRequest)?

    /// The async interceptor called after the synchronous interceptor
    /// and right before performing the network request. Can be used to
    /// modify the `URLRequest` with async operations if necessary.
    public let asyncInterceptor: (@Sendable (URLRequest) async -> URLRequest)?

    /// Initializes the network client configuration.
    /// - Parameters:
    ///   - session: The session used to perform the network requests.
    ///   - defaultDecoder: The default JSON decoder.
    ///   - defaultEncoder: The default JSON encoder.
    ///   - baseURL: The base URL component.
    ///   - interceptor: The synchronous interceptor function (optional).
    ///   - asyncInterceptor: The asynchronous interceptor function (optional).
    public init(
        session: URLSessionProtocol,
        defaultDecoder: JSONDecoder,
        defaultEncoder: JSONEncoder,
        baseURL: URL,
        interceptor: (@Sendable (URLRequest) -> URLRequest)? = nil,
        asyncInterceptor: (@Sendable (URLRequest) async -> URLRequest)? = nil
    ) {
        self.session = session
        self.defaultDecoder = defaultDecoder
        self.defaultEncoder = defaultEncoder
        self.baseURL = baseURL
        self.interceptor = interceptor
        self.asyncInterceptor = asyncInterceptor
    }
}
