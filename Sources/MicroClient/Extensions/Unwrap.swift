func unwrap<T>(
    value: T?,
    error: Error
) throws -> T {
    guard let value else {
        throw error
    }

    return value
}
