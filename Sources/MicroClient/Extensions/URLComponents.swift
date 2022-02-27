import Foundation

extension URL {

    static func makeURL<RequestModel, ResponseModel>(
        configuration: NetworkConfiguration,
        networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) throws -> URL {
        let baseURL = networkRequest.baseURL ?? configuration.baseURL

        let url = baseURL
            .appendingPathComponent(networkRequest.path)

        var components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = networkRequest.queryItems?
            .filter { $0.value != nil }

        return try unwrap(
            value: components?.url,
            error: NetworkClientError.malformedURL
        )
    }
}
