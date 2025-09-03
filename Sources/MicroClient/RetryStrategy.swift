import Foundation

/// The retry strategy for network requests.
public enum RetryStrategy: Sendable, Equatable {

    /// No retries will be attempted.
    case none

    /// Retries a specific number of times.
    case retry(count: Int)

    var count: Int {
        switch self {
        case .none: 0
        case .retry(let count): count
        }
    }
}
