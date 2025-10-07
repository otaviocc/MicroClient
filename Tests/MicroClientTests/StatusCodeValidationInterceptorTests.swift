import Foundation
import Testing

@testable import MicroClient

@Suite("StatusCodeValidationInterceptor Tests")
struct StatusCodeValidationInterceptorTests {

    @Test("It should pass valid status codes from set")
    func passesValidStatusCodesFromSet() async throws {
        // Given
        let acceptableCodes: Set<Int> = [200, 201, 204]
        let interceptor = StatusCodeValidationInterceptor(acceptableStatusCodes: acceptableCodes)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 201,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should pass valid status codes"
        )
    }

    @Test("It should throw error for invalid status codes from set")
    func throwsErrorForInvalidStatusCodesFromSet() async throws {
        // Given
        let acceptableCodes: Set<Int> = [200, 201]
        let interceptor = StatusCodeValidationInterceptor(acceptableStatusCodes: acceptableCodes)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When/Then
        do {
            _ = try await interceptor.intercept(networkResponse, Data())
            #expect(Bool(false), "It should throw NetworkClientError")
        } catch let error as NetworkClientError {
            if case let .unacceptableStatusCode(statusCode, _, _) = error {
                #expect(
                    statusCode == 404,
                    "It should include the unacceptable status code"
                )
            } else {
                #expect(Bool(false), "It should be unacceptableStatusCode error")
            }
        }
    }

    @Test("It should pass valid status codes from range")
    func passesValidStatusCodesFromRange() async throws {
        // Given
        let acceptableRange: ClosedRange<Int> = 200...299
        let interceptor = StatusCodeValidationInterceptor(acceptableRange: acceptableRange)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 250,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should pass valid status codes in range"
        )
    }

    @Test("It should throw error for status codes outside range")
    func throwsErrorForStatusCodesOutsideRange() async throws {
        // Given
        let acceptableRange: ClosedRange<Int> = 200...299
        let interceptor = StatusCodeValidationInterceptor(acceptableRange: acceptableRange)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When/Then
        do {
            _ = try await interceptor.intercept(networkResponse, Data())
            #expect(Bool(false), "It should throw NetworkClientError")
        } catch let error as NetworkClientError {
            if case let .unacceptableStatusCode(statusCode, _, _) = error {
                #expect(
                    statusCode == 404,
                    "It should include the unacceptable status code"
                )
            } else {
                #expect(Bool(false), "It should be unacceptableStatusCode error")
            }
        }
    }

    @Test("It should handle multiple ranges")
    func handlesMultipleRanges() async throws {
        // Given
        let ranges = [200...299, 304...304]
        let interceptor = StatusCodeValidationInterceptor(ranges: ranges)
        let url = try #require(URL(string: "https://example.com/api"))

        // Test 200 range
        let response200 = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse200 = try NetworkResponse(
            value: VoidResponse(),
            response: #require(response200)
        )

        // Test 304
        let response304 = HTTPURLResponse(
            url: url,
            statusCode: 304,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse304 = try NetworkResponse(
            value: VoidResponse(),
            response: #require(response304)
        )

        // When
        let result200 = try await interceptor.intercept(networkResponse200, Data())
        let result304 = try await interceptor.intercept(networkResponse304, Data())

        // Then
        #expect(
            result200.response.url == networkResponse200.response.url,
            "It should pass 200 range status codes"
        )
        #expect(
            result304.response.url == networkResponse304.response.url,
            "It should pass 304 status code"
        )
    }

    @Test("It should handle non-HTTP responses")
    func handlesNonHTTPResponses() async throws {
        // Given
        let acceptableCodes: Set<Int> = [200]
        let interceptor = StatusCodeValidationInterceptor(acceptableStatusCodes: acceptableCodes)
        let url = try #require(URL(string: "https://example.com"))
        let response = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let networkResponse = NetworkResponse(
            value: VoidResponse(),
            response: response
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should pass non-HTTP responses"
        )
    }

    @Test("It should accept 304 Not Modified with custom validation")
    func accepts304WithCustomValidation() async throws {
        // Given
        let acceptableCodes: Set<Int> = [200, 201, 304]
        let interceptor = StatusCodeValidationInterceptor(acceptableStatusCodes: acceptableCodes)
        let url = try #require(URL(string: "https://example.com/api"))
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 304,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        let networkResponse = try NetworkResponse(
            value: VoidResponse(),
            response: #require(httpResponse)
        )

        // When
        let result = try await interceptor.intercept(networkResponse, Data())

        // Then
        #expect(
            result.response.url == networkResponse.response.url,
            "It should accept 304 when included in acceptable codes"
        )
    }
}
