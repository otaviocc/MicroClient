import Foundation

extension URL {

    static func makeURL<RequestModel, ResponseModel>(
        configuration: NetworkConfiguration,
        networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) throws -> URL {
        var components = URLComponents()

        components.scheme = configuration.scheme
        components.host = configuration.hostname
        components.path = networkRequest.path
        components.queryItems = networkRequest.queryItems?
            .filter { $0.value != nil }

        return try unwrap(
            value: components.url,
            error: NetworkClientError.malformedURL
        )
    }
}
