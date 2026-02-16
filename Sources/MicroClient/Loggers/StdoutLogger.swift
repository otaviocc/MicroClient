// MIT License
//
// Copyright (c) 2026 Otávio C.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// A simple logger implementation that outputs messages to standard output (stdout).
///
/// `StdoutLogger` is a built-in logger that prints network request and response logs
/// directly to the console using Swift's `print()` function. This is useful for
/// development and debugging purposes.
///
/// The logger formats messages with the log level in brackets followed by the message:
/// ```
/// [Info] - Request: GET https://api.example.com/users
/// [Debug] - Headers: ["Content-Type": "application/json"]
/// [Error] - Transport error: The Internet connection appears to be offline.
/// ```
///
/// ## Usage
///
/// Configure the logger in your `NetworkConfiguration`:
///
/// ```swift
/// let configuration = NetworkConfiguration(
///     session: .shared,
///     defaultDecoder: JSONDecoder(),
///     defaultEncoder: JSONEncoder(),
///     baseURL: URL(string: "https://api.example.com")!,
///     logger: StdoutLogger(),
///     logLevel: .debug
/// )
/// ```
///
/// ## Log Levels
///
/// The logger respects the `NetworkLogLevel` set in the configuration:
/// - `.debug`: Shows all messages (debug, info, warning, error)
/// - `.info`: Shows info, warning, and error messages
/// - `.warning`: Shows warning and error messages
/// - `.error`: Shows only error messages
///
/// ## Thread Safety
///
/// This logger is thread-safe and conforms to `Sendable`, making it safe to use
/// with Swift's actor-based concurrency model.
public struct StdoutLogger: NetworkLogger, Sendable {

    // MARK: - Life cycle

    /// Creates a new stdout logger instance.
    ///
    /// The logger requires no configuration and will output all messages
    /// passed to it via the `log(level:message:)` method.
    public init() {}

    // MARK: - Public

    /// Logs a message to standard output with the specified level.
    ///
    /// Messages are formatted as `[Level] - message` and written directly to stdout
    /// using Foundation's `FileHandle.standardOutput` for optimal performance and
    /// control. Falls back to Swift's `print()` function if writing fails.
    ///
    /// This implementation:
    /// - Uses direct stdout writing for better performance
    /// - Handles UTF-8 encoding properly
    /// - Includes automatic newline termination
    /// - Provides graceful fallback to `print()` on errors
    ///
    /// - Parameters:
    ///   - level: The severity level of the log message
    ///   - message: The message content to log
    ///
    /// ## Example Output
    /// ```
    /// [Debug] - Request body: {"username":"john","password":"secret"}
    /// [Info] - Request: POST https://api.example.com/auth/login
    /// [Warning] - Retrying request... Attempt 1
    /// [Error] - Transport error: The request timed out.
    /// ```
    public func log(
        level: NetworkLogLevel,
        message: String
    ) {
        let formattedMessage = "[\(level.description)] - \(message)\n"

        guard let data = formattedMessage.data(using: .utf8) else {
            print("[\(level.description)] - \(message)")
            return
        }

        do {
            try FileHandle.standardOutput.write(contentsOf: data)
        } catch {
            print("[\(level.description)] - \(message)")
        }
    }
}
