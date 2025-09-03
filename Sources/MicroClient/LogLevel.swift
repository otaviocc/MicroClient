import Foundation

/// The log level for the logger.
public enum LogLevel: Int, Sendable {

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

extension LogLevel: Comparable {

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {

    public var description: String {
        switch self {
        case .debug: return "Debug"
        case .info: return "Info"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
}
