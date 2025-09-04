import Foundation

@testable import MicroClient

final class LoggerMock: NetworkLogger, @unchecked Sendable {

    // MARK: - Properties

    private(set) var loggedMessages: [(level: NetworkLogLevel, message: String)] = []

    // MARK: - Public

    func log(
        level: NetworkLogLevel,
        message: String
    ) {
        loggedMessages.append((level, message))
    }
}
