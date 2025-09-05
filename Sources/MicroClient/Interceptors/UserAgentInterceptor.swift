import Foundation

/// An interceptor that adds a User-Agent header to HTTP requests.
///
/// This interceptor automatically adds a `User-Agent` header to outgoing requests,
/// which helps identify your application to APIs and can be useful for debugging
/// and analytics. You can either provide a custom user agent string or use
/// the convenience initializer that creates one from app name and version.
///
/// - Note: The User-Agent header is always added to requests when this interceptor is used.
/// - Warning: Existing User-Agent headers will be replaced.
public struct UserAgentInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let userAgent: String

    // MARK: - Life cycle

    public init(
        appName: String,
        version: String
    ) {
        self.userAgent = "\(appName)/\(version) (iOS)"
    }

    public init(customUserAgent: String) {
        self.userAgent = customUserAgent
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return newRequest
    }
}
