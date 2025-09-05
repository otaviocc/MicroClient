import Foundation

/// An interceptor that configures custom timeout intervals for HTTP requests.
///
/// This interceptor automatically sets the timeout interval for outgoing requests.
/// This is useful for configuring different timeout behaviors for different
/// types of requests or APIs that have known performance characteristics.
///
/// - Note: The timeout interval is always applied to requests when this interceptor is used.
/// - Warning: Existing timeout intervals will be replaced.
public struct TimeoutInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let timeout: TimeInterval

    // MARK: - Life cycle

    public init(timeout: TimeInterval) {
        self.timeout = timeout
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.timeoutInterval = timeout
        return newRequest
    }
}
