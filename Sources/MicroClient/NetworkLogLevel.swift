import Foundation

/// The log level for the logger.
public enum NetworkLogLevel: Int, Sendable {

    /// Debug messages.
    case debug

    /// Info messages.
    case info

    /// Warning messages.
    case warning

    /// Error messages.
    case error
}

// MARK: - Comparable

extension NetworkLogLevel: Comparable {

    public static func < (
        lhs: NetworkLogLevel,
        rhs: NetworkLogLevel
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - CustomStringConvertible

extension NetworkLogLevel: CustomStringConvertible {

    public var description: String {
        switch self {
        case .debug: "Debug"
        case .info: "Info"
        case .warning: "Warning"
        case .error: "Error"
        }
    }
}
