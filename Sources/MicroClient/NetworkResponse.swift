import Foundation

public struct NetworkResponse<ResponseModel> {

    // MARK: - Properties

    public let value: ResponseModel
    public let response: URLResponse
}
