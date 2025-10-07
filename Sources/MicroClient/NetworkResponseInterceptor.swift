import Foundation

/// A protocol for intercepting and processing network responses after they are received and decoded.
public protocol NetworkResponseInterceptor: Sendable {

    /// Intercepts and potentially modifies a network response.
    ///
    /// This method is called for each interceptor in the chain after the response has been successfully
    /// received and decoded. It can be used to log responses, collect metrics, validate response data,
    /// handle rate limiting, or transform the response.
    ///
    /// - Parameters:
    ///   - response: The `NetworkResponse` containing the decoded value and URLResponse.
    ///   - data: The raw response data before decoding.
    /// - Returns: A potentially modified `NetworkResponse`.
    /// - Throws: An error if the interception process fails. Throwing an error will propagate to the caller.
    func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel>
}
