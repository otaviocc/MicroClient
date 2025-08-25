import Testing
import Foundation

@testable import MicroClient

@Suite("NetworkResponse with Complex Models Tests")
struct NetworkResponseComplexModelsTests {

    @Test("It should work with complex nested models")
    func workWithComplexNestedModels() throws {
        let complexModel = TestModelMother.makeComplexModel()

        let url = try #require(URL(string: "https://api.example.com/complex"))
        let httpResponse = try #require(HTTPURLResponse(
            url: url,
            statusCode: 201,
            httpVersion: "HTTP/2.0",
            headerFields: [
                "Content-Type": "application/json",
                "Location": "/api/complex/\(complexModel.id)"
            ]
        ))

        let networkResponse = NetworkResponse(
            value: complexModel,
            response: httpResponse
        )

        #expect(
            networkResponse.value == complexModel,
            "It should store the complex model"
        )
        #expect(
            networkResponse.response === httpResponse,
            "It should store the HTTPURLResponse"
        )
        if let httpUrlResponse = networkResponse.response as? HTTPURLResponse {
            #expect(
                httpUrlResponse.statusCode == 201,
                "It should preserve HTTP status code for complex models"
            )
            #expect(
                httpUrlResponse.allHeaderFields["Location"] as? String == "/api/complex/\(complexModel.id)",
                "It should preserve HTTP headers for complex models"
            )
            #expect(
                httpResponse.location?.absoluteString == "/api/complex/\(complexModel.id)",
                "It should preserve HTTP headers for complex models"
            )
        }
    }
}
