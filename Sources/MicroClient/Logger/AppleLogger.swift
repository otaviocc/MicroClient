import Foundation
import os

public struct AppleLogger: NetworkLogger, Sendable {

    // MARK: - Properties

    private let logger: Logger

    // MARK: - Life cycle

    public init(
        subsystem: String,
        category: String = "Network"
    ) {
        self.logger = Logger(
            subsystem: subsystem,
            category: category
        )
    }

    // MARK: - Public

    public func log(
        level: NetworkLogLevel,
        message: String
    ) {
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        }
    }
}
