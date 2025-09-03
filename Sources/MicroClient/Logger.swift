import Foundation

/// The logger protocol.
public protocol Logger: Sendable {

    /// Logs a message with a given level.
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The message to log.
    func log(level: LogLevel, message: String)
}

/// The default console logger.
public struct ConsoleLogger: Logger, Sendable {

    // MARK: - Life cycle

    public init() {}

    // MARK: - Public

    public func log(
        level: LogLevel,
        message: String
    ) {
        print("[\(level.description)] - \(message)")
    }
}
