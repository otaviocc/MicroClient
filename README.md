# MicroClient

[![codecov](https://codecov.io/github/otaviocc/MicroClient/graph/badge.svg?token=684ATBMZH4)](https://codecov.io/github/otaviocc/MicroClient)
[![Check Runs](https://img.shields.io/github/check-runs/otaviocc/MicroClient/main)](https://github.com/otaviocc/MicroClient/actions?query=branch%3Amain)
[![Mastodon Follow](https://img.shields.io/mastodon/follow/109580944375344260?domain=social.lol&style=flat)](https://social.lol/@otaviocc)

A lightweight, zero-dependency Swift networking library designed for type-safe HTTP requests using modern Swift concurrency.

## Features

- 🔒 **Type-safe**: Compile-time safety with generic request/response models
- ⚡ **Modern**: Built with Swift Concurrency (async/await)
- 🪶 **Lightweight**: Zero dependencies, minimal footprint
- ⚙️ **Configurable**: Global defaults with per-request customization
- 🔄 **Interceptors**: Middleware support for synchronous and asynchronous request modification
- 🔁 **Automatic Retries**: Built-in support for request retries
- 🪵 **Advanced Logging**: Customizable logging for requests and responses
- 📱 **Cross-platform**: Supports macOS 12+ and iOS 15+

## Requirements

- Swift 6.0+
- macOS 12.0+ / iOS 15.0+

## Installation

### Swift Package Manager

Add MicroClient to your project using Xcode's package manager or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/otaviocc/MicroClient", from: "0.0.17")
]
```

## Quick Start

### 1. Create a Configuration

```swift
import MicroClient

let configuration = NetworkConfiguration(
    session: .shared,
    baseURL: URL(string: "https://api.example.com")!
)

let client = NetworkClient(configuration: configuration)
```

### 2. Define Your Models

```swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct CreateUserRequest: Encodable {
    let name: String
    let email: String
}
```

### 3. Make Requests

```swift
// GET request
let getUserRequest = NetworkRequest<VoidRequest, User>(
    path: "/users/123",
    method: .get
)

let userResponse = try await client.run(getUserRequest)
let user = userResponse.value

// POST request with body
let createUserRequest = NetworkRequest<CreateUserRequest, User>(
    path: "/users",
    method: .post,
    body: CreateUserRequest(name: "John Doe", email: "john@example.com")
)

let newUserResponse = try await client.run(createUserRequest)
```

## Architecture

MicroClient is built around four core components that work together:

### NetworkClient

The main client interface providing an async/await API:

```swift
public protocol NetworkClientProtocol {
    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
}
```

### NetworkRequest

Type-safe request definitions with generic constraints:

```swift
public struct NetworkRequest<RequestModel, ResponseModel> 
where RequestModel: Encodable, ResponseModel: Decodable {
    public let path: String?
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let formItems: [URLFormItem]?
    public let body: RequestModel?
    public let additionalHeaders: [String: String]?
    public let retryStrategy: RetryStrategy?
    // ... configuration overrides
}
```

### NetworkResponse

Wraps decoded response with original URLResponse metadata:

```swift
public struct NetworkResponse<ResponseModel> {
    public let value: ResponseModel
    public let response: URLResponse
}
```

### NetworkConfiguration

Centralized configuration with override capability:

```swift
public struct NetworkConfiguration: Sendable {
    public let session: URLSessionProtocol
    public let defaultDecoder: JSONDecoder
    public let defaultEncoder: JSONEncoder
    public let baseURL: URL
    public let retryStrategy: RetryStrategy
    public let logger: Logger?
    public let logLevel: LogLevel
    public let interceptor: NetworkRequestsInterceptor?
    public let asyncInterceptor: NetworkAsyncRequestInterceptor?
}
```

## Advanced Usage

### Automatic Retries

Configure automatic retries for failed requests.

#### Global Configuration

Set a default retry strategy for all requests in `NetworkConfiguration`:

```swift
let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    retryStrategy: .retry(count: 3)
)
```

#### Per-Request Override

Override the global retry strategy for a specific request:

```swift
let request = NetworkRequest<VoidRequest, User>(
    path: "/users/123",
    method: .get,
    retryStrategy: .none // This request will not be retried
)
```

### Advanced Logging

Enable detailed logging for requests and responses.

#### Default Logger

Use the built-in `ConsoleLogger` to print logs to the console:

```swift
let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    logger: ConsoleLogger(),
    logLevel: .debug // Log debug, info, warning, and error messages
)
```

#### Custom Logger

Provide your own logger by conforming to the `Logger` protocol:

```swift
struct MyCustomLogger: Logger {
    func log(level: LogLevel, message: String) {
        // Integrate with your preferred logging framework
        print("[\(level)] - \(message)")
    }
}

let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    logger: MyCustomLogger(),
    logLevel: .info
)
```

### Request Interceptors

Modify requests before they are sent by creating a chain of objects that conform to the `NetworkRequestInterceptor` protocol. This is useful for cross-cutting concerns like adding authentication tokens, logging, or caching headers.

#### 1. Create an Interceptor

First, define a struct or class that conforms to `NetworkRequestInterceptor` and implement the `intercept` method.

```swift
// An interceptor for adding a static API key to every request.
struct APIKeyInterceptor: NetworkRequestInterceptor {
    let apiKey: String

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        return mutableRequest
    }
}

// An interceptor that asynchronously refreshes an auth token.
struct AuthTokenInterceptor: NetworkRequestInterceptor {
    let tokenProvider: TokenProviding

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        // Asynchronously get a fresh token.
        let token = await tokenProvider.getFreshToken()
        
        var mutableRequest = request
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
}
```

#### 2. Configure the Client

Add instances of your interceptors to the `NetworkConfiguration`. They will be executed in the order they appear in the array.

```swift
let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    interceptors: [
        APIKeyInterceptor(apiKey: "my-secret-key"),
        AuthTokenInterceptor(tokenProvider: myTokenProvider)
    ]
)

let client = NetworkClient(configuration: configuration)
```

#### 3. Per-Request Override (Optional)

You can also provide a specific set of interceptors for an individual request. This will override the interceptors set in the global configuration.

```swift
struct OneTimeHeaderInterceptor: NetworkRequestInterceptor {
    func intercept(_ request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue("true", forHTTPHeaderField: "X-Special-Request")
        return mutableRequest
    }
}

let request = NetworkRequest<VoidRequest, User>(
    path: "/users/123",
    method: .get,
    interceptors: [OneTimeHeaderInterceptor()] // This interceptor runs instead of the global ones.
)
```

### Custom Encoders/Decoders

Override global configuration per request:

```swift
let customDecoder = JSONDecoder()
customDecoder.dateDecodingStrategy = .iso8601

let request = NetworkRequest<VoidRequest, TimestampedResponse>(
    path: "/events",
    method: .get,
    decoder: customDecoder
)
```

### Form Data

Send form-encoded data:

```swift
let request = NetworkRequest<VoidRequest, LoginResponse>(
    path: "/auth/login",
    method: .post,
    formItems: [
        URLFormItem(name: "username", value: "user"),
        URLFormItem(name: "password", value: "pass")
    ]
)
```

### Query Parameters

Add query parameters to requests:

```swift
let request = NetworkRequest<VoidRequest, SearchResults>(
    path: "/search",
    method: .get,
    queryItems: [
        URLQueryItem(name: "q", value: "swift"),
        URLQueryItem(name: "limit", value: "10")
    ]
)
```

## Error Handling

MicroClient provides structured error handling through the `NetworkClientError` enum, giving you detailed information on what went wrong.

```swift
do {
    let response = try await client.run(request)
    // Handle success
} catch let error as NetworkClientError {
    switch error {
    case .malformedURL:
        print("Error: The URL for the request was invalid.")

    case .transportError(let underlyingError):
        print("Error: A network transport error occurred: \(underlyingError.localizedDescription)")

    case .unacceptableStatusCode(let statusCode, _, let data):
        print("Error: Server returned an unacceptable status code: \(statusCode).")
        if let data = data, let errorBody = String(data: data, encoding: .utf8) {
            print("Server response: \(errorBody)")
        }

    case .decodingError(let underlyingError):
        print("Error: Failed to decode the response: \(underlyingError.localizedDescription)")

    case .encodingError(let underlyingError):
        print("Error: Failed to encode the request body: \(underlyingError.localizedDescription)")

    case .unknown(let underlyingError):
        if let underlyingError = underlyingError {
            print("An unknown error occurred: \(underlyingError.localizedDescription)")
        } else {
            print("An unknown error occurred.")
        }
    }
} catch {
    // Handle any other errors
    print("An unexpected error occurred: \(error.localizedDescription)")
}
```

## Testing

MicroClient is designed with testing in mind. The protocol-based architecture makes it easy to create mocks.

## Development

### Building

```bash
swift build
```

### Testing

```bash
swift test
```

### Linting

SwiftLint is integrated and run during build.

## License

MicroClient is available under the MIT license. See the LICENSE file for more info.