import Foundation

public struct NetworkResponse<ResponseModel> {
    public let value: ResponseModel
    public let response: URLResponse
}
