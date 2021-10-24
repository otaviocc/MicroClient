import Combine
import Foundation

public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable {

    // MARK: - Properties

    public let path: String
    public let method: HTTPMethod
    public var parameters: [String: String]?
    public var body: RequestModel?
    public var decoder: JSONDecoder?
    public var encoder: JSONEncoder?

    // MARK: - Life cycle

    public init(
        path: String,
        method: HTTPMethod,
        parameters: [String : String]? = nil,
        body: RequestModel? = nil,
        decoder: JSONDecoder? = nil,
        encoder: JSONEncoder? = nil
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.body = body
        self.decoder = decoder
        self.encoder = encoder
    }
}

// MARK: - Query Items

extension NetworkRequest {

    public var queryItems: [URLQueryItem]? {
        parameters?.compactMap { parameter in
            URLQueryItem(
                name: parameter.key,
                value: parameter.value
            )
        }
    }
}

// MARK: - HTTP Body

extension NetworkRequest {

    public func encode(
        payload: RequestModel,
        defaultEncoder: JSONEncoder
    ) throws -> Data {
        let encoder = encoder ?? defaultEncoder
        return try encoder.encode(payload)
    }
}

// MARK: - Decode

extension NetworkRequest {

    public func decode(
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
