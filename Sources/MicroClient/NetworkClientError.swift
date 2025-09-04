import Foundation

/// An enum representing possible errors that can occur during a network request.
public enum NetworkClientError: Error {
    /// The URL for the request was malformed or invalid.
    case malformedURL

    /// The request failed due to an underlying transport error, such as a lost network connection.
    /// The associated `Error` value contains the original error from the URLSession.
    case transportError(Error)

    /// The server returned a response with an HTTP status code indicating an error (i.e., not in the 200-299 range).
    /// - `statusCode`: The HTTP status code returned by the server.
    /// - `response`: The metadata associated with the HTTP response.
    /// - `data`: The raw response body, which may contain more specific error details from the server.
    case unacceptableStatusCode(statusCode: Int, response: URLResponse, data: Data?)

    /// The response body could not be decoded into the expected `Decodable` type.
    /// The associated `Error` value contains the original decoding error.
    case decodingError(Error)

    /// The response body could not be encoded into the expected `Encodable` type.
    /// The associated `Error` value contains the original decoding error.
    case encodingError(Error)

    /// An error occurred during the execution of a request interceptor.
    case interceptorError(Error)

    /// An unexpected or unknown error occurred.
    case unknown(Error?)
}
