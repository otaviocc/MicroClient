import Foundation

public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable {

    // MARK: - Properties

    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: String]?
    public let body: RequestModel?
    public let decoder: JSONDecoder?
    public let encoder: JSONEncoder?
    public let additionalHeaders: [String: String]?

    // MARK: - Life cycle

    public init(
        path: String,
        method: HTTPMethod,
        parameters: [String: String]? = nil,
        body: RequestModel? = nil,
        decoder: JSONDecoder? = nil,
        encoder: JSONEncoder? = nil,
        additionalHeaders: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.body = body
        self.decoder = decoder
        self.encoder = encoder
        self.additionalHeaders = additionalHeaders
    }
}

// MARK: - Query Items

public extension NetworkRequest {

    var queryItems: [URLQueryItem]? {
        parameters?.compactMap { parameter in
            URLQueryItem(
                name: parameter.key,
                value: parameter.value
            )
        }
    }
}

// MARK: - HTTP Body

public extension NetworkRequest {

    func encode(
        payload: RequestModel,
        defaultEncoder: JSONEncoder
    ) throws -> Data {
        if let data = payload as? Data {
            return data
        }

        let encoder = encoder ?? defaultEncoder
        return try encoder.encode(payload)
    }
}

// MARK: - Decode

public extension NetworkRequest {

    func decode(
        data: Data,
        defaultDecoder: JSONDecoder
    ) throws -> ResponseModel {
        let decoder = decoder ?? defaultDecoder

        return try decoder.decode(
            ResponseModel.self,
            from: data
        )
    }
}
