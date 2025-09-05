import Foundation

public struct BearerAuthorizationInterceptor: NetworkRequestInterceptor {

    // MARK: - Properties

    private let tokenProvider: @Sendable () async -> String?

    // MARK: - Life cycle

    public init(
        tokenProvider: @escaping @Sendable () async -> String?
    ) {
        self.tokenProvider = tokenProvider
    }

    // MARK: - Public

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request

        if let token = await tokenProvider() {
            newRequest.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return newRequest
    }
}
