import Foundation

/// An interceptor that adds API key authentication to HTTP requests.
///
/// This interceptor automatically adds an API key header to outgoing requests.
/// The header name is configurable, with `X-API-Key` being the default.
/// This is commonly used for API authentication where a static key is required.
///
/// - Note: The API key is always added to requests when this interceptor is used.
/// - Warning: Existing headers with the same name will be replaced.
public struct APIKeyInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let apiKey: String
    private let headerName: String

    // MARK: - Life cycle

    public init(
        apiKey: String,
        headerName: String = "X-API-Key"
    ) {
        self.apiKey = apiKey
        self.headerName = headerName
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        newRequest.setValue(apiKey, forHTTPHeaderField: headerName)
        return newRequest
    }
}
