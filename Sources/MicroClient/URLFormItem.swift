import Foundation

/// A single name-value pair from the form portion of a request.
public struct URLFormItem {

    // MARK: - Properties

    /// The name of the form item.
    public let name: String

    /// The value for the form item.
    public let value: String?

    // MARK: - Life cycle

    /// Initializes a form item.
    /// - Parameters:
    ///   - name: The name of the form item.
    ///   - value: The value of the form item.
    public init(
        name: String,
        value: String?
    ) {
        self.name = name
        self.value = value
    }
}

// MARK: - Extensions

extension URLFormItem: Equatable {}
extension URLFormItem: Hashable {}

// MARK: - Array Extension

extension Array where Element == URLFormItem {

    func urlEncoded() -> Data? {
        var components = URLComponents()

        components.queryItems = self
            .map {
                .init(
                    name: $0.name,
                    value: $0.value
                )
            }
            .filter { $0.value != nil }

        return components
            .percentEncodedQuery?
            .data(
                using: .utf8
            )
    }
}
