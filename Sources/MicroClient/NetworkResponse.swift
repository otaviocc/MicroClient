import Foundation

/// The network response. It has the type
/// used as response model.
public struct NetworkResponse<ResponseModel> {

    // MARK: - Properties

    /// The decodable response model.
    public let value: ResponseModel

    /// The network response.
    public let response: URLResponse
}
