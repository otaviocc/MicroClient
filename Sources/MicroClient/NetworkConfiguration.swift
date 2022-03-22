import Foundation

/// The network client configuration.
public final class NetworkConfiguration {

    /// The session used to perform the network requests.
    public let session: URLSession

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
    public var interceptor: ((URLRequest) -> URLRequest)?

    public init(
        session: URLSession,
        defaultDecoder: JSONDecoder,
        defaultEncoder: JSONEncoder,
        baseURL: URL
    ) {
        self.session = session
        self.defaultDecoder = defaultDecoder
        self.defaultEncoder = defaultEncoder
        self.baseURL = baseURL
    }
}
