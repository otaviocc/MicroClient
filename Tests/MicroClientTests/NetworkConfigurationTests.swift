import Testing
import Foundation

@testable import MicroClient

@Suite("NetworkConfiguration Tests")
struct NetworkConfigurationTests {

    @Test("It should initialize with all required parameters")
    func initializeWithAllRequiredParameters() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com/v1"))

        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        #expect(
            (configuration.session as? URLSession) === session,
            "It should store the provided session"
        )
        #expect(
            configuration.defaultDecoder === decoder,
            "It should store the provided default decoder"
        )
        #expect(
            configuration.defaultEncoder === encoder,
            "It should store the provided default encoder"
        )
        #expect(
            configuration.baseURL == baseURL,
            "It should store the provided base URL"
        )
        #expect(
            configuration.interceptor == nil,
            "It should have nil interceptor by default"
        )
        #expect(
            configuration.asyncInterceptor == nil,
            "It should have nil async interceptor by default"
        )
    }

    @Test("It should work with custom URLSession")
    func workWithCustomURLSession() throws {
        let customSession = URLSession(configuration: .ephemeral)
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://test.example.com"))

        let configuration = NetworkConfiguration(
            session: customSession,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        #expect(
            (configuration.session as? URLSession) === customSession,
            "It should store the custom URLSession"
        )
    }

    @Test("It should work with custom JSONDecoder")
    func workWithCustomJSONDecoder() throws {
        let session = URLSession.shared
        let customDecoder = JSONDecoder()
        customDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))

        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: customDecoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        #expect(
            configuration.defaultDecoder === customDecoder,
            "It should store the custom JSONDecoder"
        )
    }

    @Test("It should work with custom JSONEncoder")
    func workWithCustomJSONEncoder() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let customEncoder = JSONEncoder()
        customEncoder.keyEncodingStrategy = .convertToSnakeCase
        let baseURL = try #require(URL(string: "https://api.example.com"))

        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: customEncoder,
            baseURL: baseURL
        )

        #expect(
            configuration.defaultEncoder === customEncoder,
            "It should store the custom JSONEncoder"
        )
    }

    @Test("It should work with different base URLs")
    func workWithDifferentBaseURLs() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        let baseURL1 = try #require(URL(string: "https://api.example.com/v1"))
        let baseURL2 = try #require(URL(string: "https://staging.example.com/api"))
        let baseURL3 = try #require(URL(string: "http://localhost:8080"))

        let configuration1 = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL1
        )

        let configuration2 = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL2
        )

        let configuration3 = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL3
        )

        #expect(
            configuration1.baseURL == baseURL1,
            "It should store the first base URL"
        )
        #expect(
            configuration2.baseURL == baseURL2,
            "It should store the second base URL"
        )
        #expect(
            configuration3.baseURL == baseURL3,
            "It should store the third base URL"
        )
    }

    @Test("It should allow setting interceptor")
    func allowSettingInterceptor() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))

        _ = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        let interceptor: @Sendable (URLRequest) -> URLRequest = { request in
            var modifiedRequest = request
            modifiedRequest.setValue("Bearer token", forHTTPHeaderField: "Authorization")
            return modifiedRequest
        }

        let configurationWithInterceptor = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            interceptor: interceptor
        )

        #expect(
            configurationWithInterceptor.interceptor != nil,
            "It should allow setting interceptor"
        )

        // Test that the interceptor works correctly
        let testURL = try #require(URL(string: "https://test.example.com"))
        let originalRequest = URLRequest(url: testURL)
        let modifiedRequest = configurationWithInterceptor.interceptor?(originalRequest)

        #expect(
            modifiedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer token",
            "It should apply the interceptor to modify requests"
        )
    }

    @Test("It should support nil interceptor")
    func supportNilInterceptor() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))

        // Create configuration without interceptor
        let configurationWithoutInterceptor = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        #expect(
            configurationWithoutInterceptor.interceptor == nil,
            "It should support nil interceptor by default"
        )

        // Create configuration with interceptor
        let configurationWithInterceptor = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            interceptor: { @Sendable request in request }
        )

        #expect(
            configurationWithInterceptor.interceptor != nil,
            "It should support non-nil interceptor when provided"
        )
    }

    @Test("It should be value type")
    func beValueType() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))

        let configuration1 = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            interceptor: { @Sendable request in request }
        )

        let configuration2 = configuration1

        #expect(
            configuration1.interceptor != nil,
            "It should have interceptor in first configuration"
        )
        #expect(
            configuration2.interceptor != nil,
            "It should copy state as a value type"
        )
        #expect(
            configuration1.baseURL == configuration2.baseURL,
            "It should have equal properties after copying"
        )
    }

    @Test("It should allow setting async interceptor")
    func allowSettingAsyncInterceptor() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))

        let asyncInterceptor: @Sendable (URLRequest) async -> URLRequest = { request in
            request
        }

        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            asyncInterceptor: asyncInterceptor
        )

        #expect(
            configuration.asyncInterceptor != nil,
            "It should allow setting async interceptor"
        )
    }

    @Test("It should support nil async interceptor")
    func supportNilAsyncInterceptor() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))

        // Create configuration without async interceptor
        let configurationWithoutAsync = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL
        )

        #expect(
            configurationWithoutAsync.asyncInterceptor == nil,
            "It should support nil async interceptor by default"
        )

        // Create configuration with async interceptor
        let configurationWithAsync = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            asyncInterceptor: { @Sendable request in request }
        )

        #expect(
            configurationWithAsync.asyncInterceptor != nil,
            "It should support non-nil async interceptor when provided"
        )
    }
}
