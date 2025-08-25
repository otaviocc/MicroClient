import Foundation

public extension URLResponse {

    /// Returns the HTTP Header value for "Location". Default: `nil`.
    var location: URL? {
        (self as? HTTPURLResponse)?
            .value(forHTTPHeaderField: "Location")
            .flatMap(URL.init(string:))
    }
}
