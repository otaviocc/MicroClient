import Foundation

extension URLRequest {

    static func makeURLRequest<RequestModel, ResponseModel>(
        configuration: NetworkConfiguration,
        networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) throws -> URLRequest {
        let url = try URL.makeURL(
            configuration: configuration,
            networkRequest: networkRequest
        )

        var request = URLRequest(url: url)
        request.httpMethod = networkRequest.method.rawValue
        request.httpBody = try networkRequest.body
            .map {
                try networkRequest.encode(
                    payload: $0,
                    defaultEncoder: configuration.defaultEncoder
                )
            }

        return request
    }
}
