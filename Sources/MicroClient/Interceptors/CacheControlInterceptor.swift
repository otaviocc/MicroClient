import Foundation

/// An interceptor that adds Cache-Control headers to HTTP requests.
///
/// This interceptor automatically adds a `Cache-Control` header to outgoing requests,
/// which controls caching behavior. You can specify different cache policies such as
/// no-cache, max-age, no-store, or provide custom cache control directives.
///
/// - Note: The Cache-Control header is always added to requests when this interceptor is used.
/// - Warning: Existing Cache-Control headers will be replaced.
public struct CacheControlInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    public enum CachePolicy: Sendable {
        case noCache
        case maxAge(seconds: Int)
        case noStore
        case custom(String)

        var headerValue: String {
            switch self {
            case .noCache: "no-cache"
            case .maxAge(let seconds): "max-age=\(seconds)"
            case .noStore: "no-store"
            case .custom(let value): value
            }
        }
    }

    private let policy: CachePolicy

    // MARK: - Life cycle

    public init(policy: CachePolicy) {
        self.policy = policy
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(policy.headerValue, forHTTPHeaderField: "Cache-Control")
        return newRequest
    }
}
