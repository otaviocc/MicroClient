import Foundation

/// An interceptor that logs response information including status code, headers, and body data.
///
/// This interceptor provides structured logging of HTTP responses to aid in debugging and monitoring.
/// It logs the HTTP status code, response headers, and the response body (if available).
public struct ResponseLoggingInterceptor: NetworkResponseInterceptor {

    // MARK: - Properties

    private let logger: NetworkLogger
    private let logLevel: NetworkLogLevel

    // MARK: - Life cycle

    public init(
        logger: NetworkLogger,
        logLevel: NetworkLogLevel = .debug
    ) {
        self.logger = logger
        self.logLevel = logLevel
    }

    // MARK: - Public

    public func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        if let httpResponse = response.response as? HTTPURLResponse {
            logger.log(
                level: logLevel,
                message: "Response interceptor - Status: \(httpResponse.statusCode)"
            )
            logger.log(
                level: logLevel,
                message: "Response interceptor - Headers: \(httpResponse.allHeaderFields)"
            )
        }

        if let bodyString = String(data: data, encoding: .utf8) {
            logger.log(
                level: logLevel,
                message: "Response interceptor - Body: \(bodyString)"
            )
        }

        return response
    }
}
