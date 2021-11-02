# MicroClient
**MicroClient** is a simple and lightweight  network client which can be used by all sorts of projects. It consists of a `NetworkClient`

```swift
public protocol NetworkClientProtocol {

    func run<RequestModel, ResponseModel>(
        _ networkRequest: NetworkRequest<RequestModel, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
}
```

which takes a `NetworkRequest`

```swift
public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable
```

and returns a `NetworkResponse`

```swift
public struct NetworkResponse<ResponseModel> {
    public let value: ResponseModel
    public let response: URLResponse
}
```

## Configuration
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

    /// The scheme component of the base URL.
    public let scheme: String

    /// The host component of the base URL.
    public let hostname: String

    /// The interceptor called right before performing the
    /// network request. Can be used to modify the `URLRequest`
    /// if necessary.
    public var interceptor: ((URLRequest) -> URLRequest)?
}
```

## Building Requests
Requests are built with `NetworkRequest`. Example:

```swift
let request = NetworkRequest<VoidRequest, PostsResponse>(
    path: "/posts/bookmarks",
    method: .get
}
```

In the example above, the response object is `PostsResponse`, a type which conforms to `Decodable`.

The `NetworkRequest` allows custom encoders and decoders for the request, overriding the default ones from the `NetworkConfiguration`.

```swift
public struct NetworkRequest<
    RequestModel,
    ResponseModel
> where RequestModel: Encodable, ResponseModel: Decodable {
    public let path: String
    public let method: HTTPMethod
    public var parameters: [String: String]?
    public var body: RequestModel?
    public var decoder: JSONDecoder?
    public var encoder: JSONEncoder?
    public var additionalHeaders: [String: String]?
}
```

## Example
* [MicroAPI: µ API - a Micro.blog API client](https://github.com/otaviocc/MicroAPI) uses MicroClient to access Micro.blog APIs. It also implements photo upload - `multipart/form-data` - using MicroClient.
