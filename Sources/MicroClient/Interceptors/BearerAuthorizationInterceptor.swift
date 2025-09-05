import Foundation

/// An interceptor that adds Bearer token authorization to HTTP requests.
///
/// This interceptor automatically adds an `Authorization` header with a Bearer token
/// to outgoing requests. The token is provided through an asynchronous closure,
/// allowing for dynamic token retrieval or refresh.
///
/// - Note: If the token provider returns `nil`, no Authorization header is added.
/// - Warning: Existing Authorization headers will be replaced when a token is provided.
public struct BearerAuthorizationInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let tokenProvider: @Sendable () async -> String?

    // MARK: - Life cycle

    public init(
        tokenProvider: @escaping @Sendable () async -> String?
    ) {
        self.tokenProvider = tokenProvider
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request

        if let token = await tokenProvider() {
            newRequest.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return newRequest
    }
}
