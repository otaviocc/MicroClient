import Foundation

/// Protocol for URLSession to enable dependency injection and testing
public protocol URLSessionProtocol {

    /// Performs a network request and returns data and response.
    ///
    /// - Parameter request: The URL request to perform.
    /// - Parameter delegate: The delegate for the request (optional).
    /// - Returns: A tuple containing the response data and URLResponse.
    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
}

// MARK: - URLSession conformance

extension URLSession: URLSessionProtocol {}
