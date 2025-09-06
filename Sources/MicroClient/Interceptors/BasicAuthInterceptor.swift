import Foundation

/// An interceptor that adds Basic authentication to HTTP requests.
///
/// This interceptor automatically adds an `Authorization` header with Basic
/// authentication credentials to outgoing requests. The credentials are provided
/// through an asynchronous closure, allowing for dynamic credential retrieval
/// or refresh. The username and password are Base64 encoded as required by the
/// Basic authentication scheme.
///
/// - Note: If the credentials provider returns `nil`, no Authorization header is added.
/// - Warning: Existing Authorization headers will be replaced when credentials are provided.
public struct BasicAuthInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let credentialsProvider: @Sendable () async -> (username: String, password: String)?

    // MARK: - Life cycle

    /// Creates a Basic Authentication interceptor with an async credentials provider.
    ///
    /// - Parameter credentialsProvider: An async closure that returns the username and password
    ///   for Basic authentication. Return `nil` to skip adding the Authorization header.
    public init(
        credentialsProvider: @escaping @Sendable () async -> (username: String, password: String)?
    ) {
        self.credentialsProvider = credentialsProvider
    }

    /// Creates a Basic Authentication interceptor with static credentials.
    ///
    /// This convenience initializer creates a closure that always returns the same credentials.
    ///
    /// - Parameters:
    ///   - username: The username for Basic authentication
    ///   - password: The password for Basic authentication
    public init(
        username: String,
        password: String
    ) {
        credentialsProvider = { (username, password) }
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request

        if let credentials = await credentialsProvider() {
            let credentialsString = "\(credentials.username):\(credentials.password)"
            let base64Credentials = Data(credentialsString.utf8).base64EncodedString()
            newRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }

        return newRequest
    }
}
