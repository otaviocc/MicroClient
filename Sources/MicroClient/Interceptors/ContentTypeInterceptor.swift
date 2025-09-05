import Foundation

/// An interceptor that adds Content-Type headers to HTTP requests with a body.
///
/// This interceptor automatically adds a `Content-Type` header to outgoing requests
/// that have an HTTP body. This is commonly used for JSON APIs where you want to
/// ensure all requests with bodies are properly labeled. The default content type
/// is `application/json`, but it can be customized.
///
/// - Note: Content-Type is only added to requests that have an HTTP body.
/// - Warning: Existing Content-Type headers will be replaced.
public struct ContentTypeInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let contentType: String

    // MARK: - Life cycle

    public init(contentType: String = "application/json") {
        self.contentType = contentType
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request

        if newRequest.httpBody != nil {
            newRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        return newRequest
    }
}
