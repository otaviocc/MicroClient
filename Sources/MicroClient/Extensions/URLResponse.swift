import Foundation

extension URLResponse {

    /// Returns the HTTP Header value for "Location". Default: `nil`.
    public var location: URL? {
        (self as? HTTPURLResponse)?
            .value(forHTTPHeaderField: "Location")
            .flatMap(URL.init(string:))
    }
}
