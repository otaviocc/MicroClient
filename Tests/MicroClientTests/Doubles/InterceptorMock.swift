import Foundation

@testable import MicroClient

struct InterceptorMock: NetworkRequestInterceptor {

    // MARK: - Properties

    let id = UUID()

    // MARK: - Public

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        return request
    }
}
