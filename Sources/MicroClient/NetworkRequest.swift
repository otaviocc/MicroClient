import Foundation

public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable {

    // MARK: - Properties

    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let formItems: [URLFormItem]?
    public let body: RequestModel?
    public let decoder: JSONDecoder?
    public let encoder: JSONEncoder?
    public let additionalHeaders: [String: String]?

    // MARK: - Life cycle

    public init(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        formItems: [URLFormItem]? = nil,
        body: RequestModel? = nil,
        decoder: JSONDecoder? = nil,
        encoder: JSONEncoder? = nil,
        additionalHeaders: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.formItems = formItems
        self.body = body
        self.decoder = decoder
        self.encoder = encoder
        self.additionalHeaders = additionalHeaders
    }
}

// MARK: - HTTP Body

extension NetworkRequest {

    func httpBody(
        defaultEncoder: JSONEncoder
    ) throws -> Data? {
        guard formItems == nil else {
            return formItems?.urlEncoded()
        }

        return try body.map { payload in
            try encode(
                payload: payload,
                defaultEncoder: defaultEncoder
            )
        }
    }
}

// MARK: - Encode

extension NetworkRequest {

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

extension NetworkRequest {

    func decode(
        data: Data,
        defaultDecoder: JSONDecoder
    ) throws -> ResponseModel {
        guard ResponseModel.self != VoidResponse.self else {
            return VoidResponse() as! ResponseModel
        }

        let decoder = decoder ?? defaultDecoder

        return try decoder.decode(
            ResponseModel.self,
            from: data
        )
    }
}
