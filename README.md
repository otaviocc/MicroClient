# MicroClient

[![codecov](https://codecov.io/github/otaviocc/MicroClient/graph/badge.svg?token=684ATBMZH4)](https://codecov.io/github/otaviocc/MicroClient)
[![Check Runs](https://img.shields.io/github/check-runs/otaviocc/MicroClient/main)](https://github.com/otaviocc/MicroClient/actions?query=branch%3Amain)
[![Mastodon Follow](https://img.shields.io/mastodon/follow/109580944375344260?domain=social.lol&style=flat)](https://social.lol/@otaviocc)

A lightweight, zero-dependency Swift networking library designed for type-safe HTTP requests using modern Swift concurrency.

## Features

- 🔒 **Type-safe**: Compile-time safety with generic request/response models
- ⚡ **Modern**: Built with async/await and Combine integration
- 🪶 **Lightweight**: Zero dependencies, minimal footprint
- ⚙️ **Configurable**: Global defaults with per-request customization
- 🔄 **Interceptors**: Middleware support for request modification
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

The main client interface providing async/await API and Combine integration:

```swift
public protocol NetworkClientProtocol {
    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
    
    func statusPublisher() -> AnyPublisher<NetworkClientStatus, Never>
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
public final class NetworkConfiguration {
    public let session: URLSession
    public let defaultDecoder: JSONDecoder
    public let defaultEncoder: JSONEncoder
    public let baseURL: URL
    public var interceptor: ((URLRequest) -> URLRequest)?
}
```

## Advanced Usage

### Request Interceptors

Modify requests before they're sent:

```swift
configuration.interceptor = { request in
    var mutableRequest = request
    mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return mutableRequest
}
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

### Status Monitoring

Monitor client activity with Combine:

```swift
client.statusPublisher()
    .sink { status in
        switch status {
        case .idle:
            print("Client is idle")
        case .running:
            print("Client is performing request")
        }
    }
    .store(in: &cancellables)
```

## Error Handling

MicroClient provides structured error handling:

```swift
do {
    let response = try await client.run(request)
    // Handle success
} catch let error as NetworkClientError {
    switch error {
    case .invalidURL:
        // Handle invalid URL
    case .noData:
        // Handle empty response
    case .decodingError(let underlyingError):
        // Handle JSON decoding errors
    case .networkError(let underlyingError):
        // Handle network errors
    }
} catch {
    // Handle other errors
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
