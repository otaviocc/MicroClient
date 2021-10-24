import Foundation

public struct NetworkResponse<T> {
    public let value: T
    public let response: URLResponse
}
