import Foundation

extension URL {

    static func makeURL(
        configuration: NetworkConfiguration,
        networkRequest: NetworkRequest<some Any, some Any>
    ) throws -> URL {
        var url = networkRequest.baseURL ?? configuration.baseURL

        if let path = networkRequest.path {
            url.appendPathComponent(path)
        }

        var components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )

        let queryItems = networkRequest
            .queryItems
            .filter { $0.value != nil }

        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        return try unwrap(
            value: components?.url,
            error: NetworkClientError.malformedURL
        )
    }
}
