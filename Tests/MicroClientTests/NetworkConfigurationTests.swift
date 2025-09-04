import Testing
import Foundation

@testable import MicroClient

// swiftlint:disable type_body_length

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
            configuration.interceptors.isEmpty,
            "It should have an empty interceptors array by default"
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

    @Test("It should allow setting interceptors")
    func allowSettingInterceptors() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))
        let interceptor1 = InterceptorMock()
        let interceptor2 = InterceptorMock()

        let configuration = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            interceptors: [interceptor1, interceptor2]
        )

        #expect(
            configuration.interceptors.count == 2,
            "It should store the provided interceptors"
        )
    }

    @Test("It should be a value type")
    func beValueType() throws {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let baseURL = try #require(URL(string: "https://api.example.com"))
        let interceptor = InterceptorMock()

        let configuration1 = NetworkConfiguration(
            session: session,
            defaultDecoder: decoder,
            defaultEncoder: encoder,
            baseURL: baseURL,
            interceptors: [interceptor]
        )

        let configuration2 = configuration1

        #expect(
            !configuration1.interceptors.isEmpty,
            "It should have interceptors in the first configuration"
        )
        #expect(
            !configuration2.interceptors.isEmpty,
            "It should copy the interceptors as a value type"
        )
        #expect(
            configuration1.baseURL == configuration2.baseURL,
            "It should have equal properties after copying"
        )
    }
}

// swiftlint:enable type_body_length
