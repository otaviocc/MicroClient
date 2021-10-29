import Foundation

func unwrap<T>(
    value: T?,
    error: Error
) throws -> T {
    guard let value = value else {
        throw error
    }

    return value
}
