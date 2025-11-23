import Foundation

@testable import MicroClient

final class URLSessionMock: URLSessionProtocol, @unchecked Sendable {

    // MARK: - Properties

    private(set) var lastRequest: URLRequest?
    private(set) var requestCount = 0
    private var stubbedDataToReturn = Data()
    private var stubbedResponseToReturn = URLResponse()
    private var stubbedErrorToThrow: Error?
    var succeedAfter = 0
    var delay: TimeInterval = 0

    // MARK: - Public

    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        lastRequest = request
        requestCount += 1

        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        if succeedAfter > 0, requestCount > succeedAfter {
            // Do not throw error, return stubbed data
        } else if let error = stubbedErrorToThrow {
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
