import Foundation

/// An interceptor that adds unique request IDs to HTTP requests.
///
/// This interceptor automatically adds a unique identifier header to outgoing requests.
/// Each request gets a UUID that can be used for tracing, debugging, and correlating
/// requests with responses in logs. The header name is configurable, with `X-Request-ID`
/// being the default.
///
/// - Note: A new UUID is generated for each request when this interceptor is used.
/// - Warning: Existing headers with the same name will be replaced.
public struct RequestIDInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let headerName: String

    // MARK: - Life cycle

    public init(headerName: String = "X-Request-ID") {
        self.headerName = headerName
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        let requestID = UUID().uuidString
        newRequest.setValue(requestID, forHTTPHeaderField: headerName)
        return newRequest
    }
}
