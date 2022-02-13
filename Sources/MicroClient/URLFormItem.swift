import Foundation

public struct URLFormItem {

    // MARK: - Properties

    /// The name of the form item.
    public let name: String

    /// The value for the form item.
    public let value: String?

    // MARK: - Life cycle

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

        components.queryItems = map {
            .init(
                name: $0.name,
                value: $0.value
            )
        }

        return components
            .percentEncodedQuery?
            .data(
                using: .utf8
            )
    }
}
