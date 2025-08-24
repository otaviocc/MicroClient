import Testing
import Foundation
@testable import MicroClient

@Suite("NetworkResponse Tests")
struct NetworkResponseTests {

    @Test("It should initialize with value and URLResponse")
    func initializeWithValueAndURLResponse() throws {
        let testValue = "test response"
        let url = try #require(URL(string: "https://example.com"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: 100,
            textEncodingName: nil
        )

        let networkResponse = NetworkResponse(
            value: testValue,
            response: urlResponse
        )

        #expect(
            networkResponse.value == testValue,
            "It should store the provided value"
        )
        #expect(
            networkResponse.response === urlResponse,
            "It should store the provided URLResponse"
        )
    }

    @Test("It should work with Decodable struct")
    func workWithDecodableStruct() throws {
        struct TestModel: Decodable, Equatable {
            let id: Int
            let name: String
        }

        let testModel = TestModel(id: 123, name: "Test")
        let url = try #require(URL(string: "https://api.example.com/users/123"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: 50,
            textEncodingName: "utf-8"
        )

        let networkResponse = NetworkResponse(
            value: testModel,
            response: urlResponse
        )

        #expect(
            networkResponse.value == testModel,
            "It should store the decoded model"
        )
        #expect(
            networkResponse.response === urlResponse,
            "It should store the URLResponse"
        )
    }

    @Test("It should work with VoidResponse")
    func workWithVoidResponse() throws {
        let voidResponse = VoidResponse()
        let url = try #require(URL(string: "https://api.example.com/delete"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        let networkResponse = NetworkResponse(
            value: voidResponse,
            response: urlResponse
        )

        #expect(
            networkResponse.response === urlResponse,
            "It should store the URLResponse"
        )
    }

    @Test("It should work with HTTPURLResponse")
    func workWithHTTPURLResponse() throws {
        struct APIResponse: Decodable, Equatable {
            let success: Bool
            let message: String
        }

        let apiResponse = APIResponse(success: true, message: "Operation completed")
        let url = try #require(URL(string: "https://api.example.com/status"))
        let httpResponse = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": "application/json",
                "Content-Length": "42"
            ]
        ))

        let networkResponse = NetworkResponse(
            value: apiResponse,
            response: httpResponse
        )

        #expect(
            networkResponse.value == apiResponse,
            "It should store the API response"
        )
        #expect(
            networkResponse.response === httpResponse,
            "It should store the HTTPURLResponse"
        )

        // Verify we can cast to HTTPURLResponse to access HTTP-specific properties
        if let httpUrlResponse = networkResponse.response as? HTTPURLResponse {
            #expect(
                httpUrlResponse.statusCode == 200,
                "It should preserve HTTP status code"
            )
            #expect(
                httpUrlResponse.allHeaderFields["Content-Type"] as? String == "application/json",
                "It should preserve HTTP headers"
            )
        }
    }

    @Test("It should work with Array response models")
    func workWithArrayResponseModels() throws {
        struct User: Decodable, Equatable {
            let id: Int
            let username: String
        }

        let users = [
            User(id: 1, username: "alice"),
            User(id: 2, username: "bob"),
            User(id: 3, username: "charlie")
        ]

        let url = try #require(URL(string: "https://api.example.com/users"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: 200,
            textEncodingName: "utf-8"
        )

        let networkResponse = NetworkResponse(
            value: users,
            response: urlResponse
        )

        #expect(
            networkResponse.value.count == 3,
            "It should store the array of users"
        )
        #expect(
            networkResponse.value == users,
            "It should store the exact user array"
        )
        #expect(
            networkResponse.response === urlResponse,
            "It should store the URLResponse"
        )
    }

    @Test("It should work with Optional response models")
    func workWithOptionalResponseModels() throws {
        let optionalValue: String? = "optional response"
        let url = try #require(URL(string: "https://api.example.com/optional"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: 17,
            textEncodingName: "utf-8"
        )

        let networkResponse = NetworkResponse(
            value: optionalValue,
            response: urlResponse
        )

        #expect(
            networkResponse.value == "optional response",
            "It should store the optional value"
        )
        #expect(
            networkResponse.response === urlResponse,
            "It should store the URLResponse"
        )
    }

    @Test("It should work with nil Optional response models")
    func workWithNilOptionalResponseModels() throws {
        let optionalValue: String? = nil
        let url = try #require(URL(string: "https://api.example.com/empty"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: 0,
            textEncodingName: nil
        )

        let networkResponse = NetworkResponse(
            value: optionalValue,
            response: urlResponse
        )

        #expect(
            networkResponse.value == nil,
            "It should store nil value"
        )
        #expect(
            networkResponse.response === urlResponse,
            "It should store the URLResponse"
        )
    }

    @Test("It should work with primitive types")
    func workWithPrimitiveTypes() throws {
        let intValue = 42
        let url = try #require(URL(string: "https://api.example.com/count"))
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: 2,
            textEncodingName: "utf-8"
        )

        let networkResponse = NetworkResponse(
            value: intValue,
            response: urlResponse
        )

        #expect(
            networkResponse.value == 42,
            "It should store the integer value"
        )
        #expect(
            networkResponse.response === urlResponse,
            "It should store the URLResponse"
        )
    }

    @Test("It should preserve URLResponse properties")
    func preserveURLResponseProperties() throws {
        let responseValue = "test data"
        let url = try #require(URL(string: "https://example.com/data.json"))
        let mimeType = "application/json"
        let expectedContentLength: Int = 1024
        let textEncodingName = "utf-8"

        let urlResponse = URLResponse(
            url: url,
            mimeType: mimeType,
            expectedContentLength: expectedContentLength,
            textEncodingName: textEncodingName
        )

        let networkResponse = NetworkResponse(
            value: responseValue,
            response: urlResponse
        )

        #expect(
            networkResponse.response.url == url,
            "It should preserve the URL"
        )
        #expect(
            networkResponse.response.mimeType == mimeType,
            "It should preserve the MIME type"
        )
        #expect(
            networkResponse.response.expectedContentLength == expectedContentLength,
            "It should preserve the expected content length"
        )
        #expect(
            networkResponse.response.textEncodingName == textEncodingName,
            "It should preserve the text encoding name"
        )
    }
}
