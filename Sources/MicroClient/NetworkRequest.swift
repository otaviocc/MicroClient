import Foundation

public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable {

    // MARK: - Properties

    /// The request `/path`, used in combination with the
    /// `NetworkConfiguration.baseURL`.
    public let path: String

    /// The HTTP request method.
    public let method: HTTPMethod

    /// The query URL component as an array of name/value pairs.
    public let queryItems: [URLQueryItem]?

    /// The data sent as the message body of a request as
    /// form item as for an HTTP POST request.
    public let formItems: [URLFormItem]?

    /// The base URL used for the request. If present, it overrides
    /// `NetworkConfiguration.baseURL`.
    public let baseURL: URL?

    /// The data sent as the message body of a request, such
    /// as for an HTTP POST request.
    public let body: RequestModel?

    /// The decoder used to decode the `ResponseModel`. If not not
    /// specified `NetworkConfiguration.defaultDecoder`.
    /// is used instead.
    public let decoder: JSONDecoder?

    /// The encoder used to encode the `RequestModel`. If not not
    /// specified `NetworkConfiguration.defaultEncoder`.
    /// is used instead.
    public let encoder: JSONEncoder?

    /// A dictionary containing additional header fields
    /// for the request.
    public let additionalHeaders: [String: String]?

    // MARK: - Life cycle

    public init(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        formItems: [URLFormItem]? = nil,
        body: RequestModel? = nil,
        baseURL: URL? = nil,
        decoder: JSONDecoder? = nil,
        encoder: JSONEncoder? = nil,
        additionalHeaders: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.formItems = formItems
        self.body = body
        self.baseURL = baseURL
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
