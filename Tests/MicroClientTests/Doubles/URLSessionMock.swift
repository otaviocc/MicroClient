import Foundation

@testable import MicroClient

final class URLSessionMock: URLSessionProtocol, @unchecked Sendable {

    // MARK: - Properties

    private(set) var lastRequest: URLRequest?
    private var stubbedDataToReturn: Data = Data()
    private var stubbedResponseToReturn: URLResponse = URLResponse()
    private var stubbedErrorToThrow: Error?

    // MARK: - Public

    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        lastRequest = request

        if let error = stubbedErrorToThrow {
            throw error
        }

        return (stubbedDataToReturn, stubbedResponseToReturn)
    }
}

// MARK: - Stub

extension URLSessionMock {

    func stubDataToReturn(
        data: Data,
        response: URLResponse
    ) {
        stubbedDataToReturn = data
        stubbedResponseToReturn = response
    }

    func stubDataToThrow(error: Error?) {
        stubbedErrorToThrow = error
    }
}
