import Foundation

@testable import MicroClient

struct ThrowingInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    struct MockError: Error {}

    // MARK: - Public

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        throw MockError()
    }
}
