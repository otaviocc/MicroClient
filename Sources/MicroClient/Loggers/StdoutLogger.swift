import Foundation

public struct StdoutLogger: NetworkLogger, Sendable {

    // MARK: - Life cycle

    public init() {}

    // MARK: - Public

    public func log(
        level: NetworkLogLevel,
        message: String
    ) {
        print("[\(level.description)] - \(message)")
    }
}
