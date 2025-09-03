/// Network client errors when building requests.
public enum NetworkClientError: Error {

    /// Invalid URL. Either when building URL components
    /// or with the base URL.
    case malformedURL

    /// An unknown error.
    case unknown
}
