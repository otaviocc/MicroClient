import Foundation

/// An interceptor that adds Accept headers to HTTP requests.
///
/// This interceptor automatically adds an `Accept` header to outgoing requests,
/// which tells the server what content types the client can handle. This is
/// useful for content negotiation with APIs that can return different formats.
/// The default accept type is `application/json`.
///
/// - Note: The Accept header is always added to requests when this interceptor is used.
/// - Warning: Existing Accept headers will be replaced.
public struct AcceptHeaderInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let acceptType: String

    // MARK: - Life cycle

    public init(acceptType: String = "application/json") {
        self.acceptType = acceptType
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(acceptType, forHTTPHeaderField: "Accept")
        return newRequest
    }
}
