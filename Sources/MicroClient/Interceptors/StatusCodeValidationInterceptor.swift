import Foundation

/// An interceptor that validates HTTP status codes against a custom range or set of acceptable codes.
///
/// This interceptor provides flexible status code validation beyond the default 200-299 range.
/// It can be configured to accept specific status codes or ranges, making it useful for APIs
/// that use non-standard success codes (e.g., 304 Not Modified, or custom 2xx codes).
public struct StatusCodeValidationInterceptor: NetworkResponseInterceptor {

    // MARK: - Properties

    private let acceptableStatusCodes: Set<Int>

    // MARK: - Life cycle

    public init(
        acceptableStatusCodes: Set<Int>
    ) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }

    public init(
        acceptableRange: ClosedRange<Int>
    ) {
        acceptableStatusCodes = Set(acceptableRange)
    }

    public init(
        ranges: [ClosedRange<Int>]
    ) {
        var codes = Set<Int>()
        for range in ranges {
            codes.formUnion(range)
        }
        acceptableStatusCodes = codes
    }

    // MARK: - Public

    public func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response
        }

        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            throw NetworkClientError.unacceptableStatusCode(
                statusCode: httpResponse.statusCode,
                response: httpResponse,
                data: data
            )
        }

        return response
    }
}
