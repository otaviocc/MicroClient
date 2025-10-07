import Foundation

@testable import MicroClient

final class ResponseInterceptorMock: NetworkResponseInterceptor, @unchecked Sendable {

    // MARK: - Properties

    var interceptCalled = false
    var interceptCallCount = 0
    var lastResponse: Any?
    var lastData: Data?
    var errorToThrow: Error?

    // MARK: - Public

    func intercept<ResponseModel>(
        _ response: NetworkResponse<ResponseModel>,
        _ data: Data
    ) async throws -> NetworkResponse<ResponseModel> {
        interceptCalled = true
        interceptCallCount += 1
        lastResponse = response
        lastData = data

        if let error = errorToThrow {
            throw error
        }

        return response
    }
}
