import Foundation

@testable import MicroClient

struct HeaderInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    let headerName: String
    let headerValue: String
    let storage: MockInterceptorStorage

    // MARK: - Public

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        await storage.recordCall(id: headerName)

        var mutableRequest = request
        mutableRequest.setValue(
            headerValue,
            forHTTPHeaderField: headerName
        )
        return mutableRequest
    }
}
