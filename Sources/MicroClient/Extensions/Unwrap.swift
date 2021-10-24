import Combine

func unwrap<T>(
    value: T?,
    error: Error
) throws -> T {
    guard let value = value else {
        throw error
    }

    return value
}

extension Publisher {

    func unwrap<T>(
        with error: Failure
    ) -> Publishers.FlatMap<Result<T, Self.Failure>.Publisher, Self> where Output == T? {
        flatMap { unwrapped in
            unwrapped.map { value in
                Result.success(value).publisher
            } ?? Result.failure(error).publisher
        }
    }
}
