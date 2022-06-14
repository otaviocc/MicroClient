# MicroClient

**Simple** and **lightweight** network client which can be used by all sorts of projects.

## Components

The main components are:

* ``NetworkClient``: The network client itself. The client is a concrete implementation of the ``NetworkClientProtocol`` protocol.
* ``NetworkRequest``: The request definition.
* ``NetworkResponse``: The network response, containing both the `URLResponse` and the decodable response.
* ``NetworkConfiguration``: The network client configuration.

### Network Client

The network client interface is initialized with its configuration, ``NetworkConfiguration``, and contains a method which performs the network request, `NetworkClientProtocol.run(_:)`.

```swift
public protocol NetworkClientProtocol {
    init(configuration: NetworkConfiguration)

    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
}
```

### Network Request

The network request contains two types, `RequestModel` and `ResponseModel`. These types conform to `Encodable` and `Decodable` protocols, respectively.

```swift
public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable
```

The network request can be initialized with several properties, most of them optional, used to override the network configuration when applicable. E.g., the network client might need to use a different decoder or encoder for the request, or might require additional headers. 

### Network Response

As previously mentioned, the network request contains both the original `URLResponse` and the payload decodable to `ResponseModel`.

```swift
public struct NetworkResponse<ResponseModel> {
    public let value: ResponseModel
    public let response: URLResponse
}
```

### Configuration

The network client can be configured with default encoders and decoders, hostname, session, etc...

```swift
public final class NetworkConfiguration {

    /// The session used to perform the network requests.
    public let session: URLSession

    /// The default JSON decoder. It can be overwritten by
    /// individual requests, if necessary.
    public let defaultDecoder: JSONDecoder

    /// The default JSON encoder. It can be overwritten by
    /// individual requests, if necessary.
    public let defaultEncoder: JSONEncoder

    /// The base URL component.
    /// E.g., `https://hostname.com/api/v3`
    public let baseURL: URL

    /// The interceptor called right before performing the
    /// network request. Can be used to modify the `URLRequest`
    /// if necessary.
    public var interceptor: ((URLRequest) -> URLRequest)?
}
```

## Building Requests

Requests are built by creating ``NetworkRequest`` instances. Below, a simple `GET` requests which retrieves a list of posts bookmarked by the user.  The network response is `PostsResponse`, which conforms to the `Decodable` protocol.

```swift
let request = NetworkRequest<VoidRequest, PostsResponse>(
    path: "/posts/bookmarks",
    method: .get
}
```

The `NetworkRequest` allows custom encoders and decoders for the request, overriding the default ones from the `NetworkConfiguration`.

```swift
public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable {

    /// The request `/path`, used in combination with the
    /// `NetworkConfiguration.baseURL`.
    public let path: String?

    /// The HTTP request method.
    public let method: HTTPMethod

    /// The query URL component as an array of name/value pairs.
    public let queryItems: [URLQueryItem]?

    /// The data sent as the message body of a request as
    /// form item as for an HTTP POST request.
    public let formItems: [URLFormItem]?

    /// The base URL used for the request. If present, it overrides
    /// `NetworkConfiguration.baseURL`.
    public let baseURL: URL?

    /// The data sent as the message body of a request, such
    /// as for an HTTP POST request.
    public let body: RequestModel?

    /// The decoder used to decode the `ResponseModel`. If not not
    /// specified `NetworkConfiguration.defaultDecoder`.
    /// is used instead.
    public let decoder: JSONDecoder?

    /// The encoder used to encode the `RequestModel`. If not not
    /// specified `NetworkConfiguration.defaultEncoder`.
    /// is used instead.
    public let encoder: JSONEncoder?

    /// A dictionary containing additional header fields
    /// for the request.
    public let additionalHeaders: [String: String]?
}
```

## Performing Requests

A network requests is performed by calling  `NetworkClientProtocol.run(_:)`.

```swift
// Returns NetworkRequest<VoidRequest, PostsResponse>
let bookmarksRequest = PostsAPIFactory.makeBookmarksRequest()

// Returns NetworkResponse<PostsResponse> 
let bookmarksResponse = try await client.run(bookmarksRequest)
```

## Examples

* [MicroblogAPI](https://github.com/otaviocc/MicroblogAPI) uses MicroClient to access Micro.blog APIs. It also implements photo upload - `multipart/form-data` - using MicroClient.
* [MicroPinboardAPI](https://github.com/otaviocc/MicroPinboardAPI) uses MicroClient to access Pinboard's APIs.
* [MicropubAPI](https://github.com/otaviocc/MicropubAPI) uses MicroClient to access Micropub APIs.
