import Foundation

@testable import MicroClient

final class URLSessionMock: URLSessionProtocol {
    var dataToReturn: Data = Data()
    var responseToReturn: URLResponse = URLResponse()
    var errorToThrow: Error?
    var lastRequest: URLRequest?

    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        lastRequest = request

        if let error = errorToThrow {
            throw error
        }

        return (dataToReturn, responseToReturn)
    }
}
