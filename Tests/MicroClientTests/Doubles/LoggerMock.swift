import Foundation

@testable import MicroClient

final class LoggerMock: Logger, @unchecked Sendable {

    // MARK: - Properties

    private(set) var loggedMessages: [(level: LogLevel, message: String)] = []

    // MARK: - Public

    func log(
        level: LogLevel,
        message: String
    ) {
        loggedMessages.append((level, message))
    }
}
