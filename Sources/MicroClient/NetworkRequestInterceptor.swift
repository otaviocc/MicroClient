import Foundation

/// A protocol for intercepting and modifying network requests before they are sent.
public protocol NetworkRequestInterceptor: Sendable {

    /// Intercepts and potentially modifies a URLRequest.
    ///
    /// This method is called for each interceptor in the chain. It can be used to add headers,
    /// modify the request body, or even perform asynchronous tasks like refreshing an authentication token.
    ///
    /// - Parameter request: The `URLRequest` to be processed.
    /// - Returns: A potentially modified `URLRequest`.
    /// - Throws: An error if the interception process fails. Throwing an error will cancel the entire request.
    func intercept(_ request: URLRequest) async throws -> URLRequest
}
