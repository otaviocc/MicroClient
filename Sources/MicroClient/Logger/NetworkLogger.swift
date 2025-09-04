import Foundation

/// The logger protocol.
public protocol NetworkLogger: Sendable {

    /// Logs a message with a given level.
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The message to log.
    func log(
        level: NetworkLogLevel,
        message: String
    )
}
