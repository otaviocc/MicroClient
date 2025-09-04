import Foundation
import os

public struct AppleLogger: NetworkLogger, Sendable {

    // MARK: - Properties

    private let logger = Logger()

    // MARK: - Life cycle

    public init() {}

    // MARK: - Public

    public func log(
        level: NetworkLogLevel,
        message: String
    ) {
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        }
    }
}
