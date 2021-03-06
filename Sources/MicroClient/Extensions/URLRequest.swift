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
        request.httpBody = try networkRequest.httpBody(
            defaultEncoder: configuration.defaultEncoder
        )

        networkRequest.additionalHeaders?.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
