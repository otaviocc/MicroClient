import Testing
import Foundation
@testable import MicroClient

@Suite("NetworkResponse with Complex Models Tests")
struct NetworkResponseComplexModelsTests {

    struct ComplexModel: Decodable, Equatable {
        let id: UUID
        let metadata: [String: String]
        let timestamps: [Date]
        let isActive: Bool

        static func == (
            lhs: ComplexModel,
            rhs: ComplexModel
        ) -> Bool {
            lhs.id == rhs.id &&
                   lhs.metadata == rhs.metadata &&
                   lhs.timestamps == rhs.timestamps &&
                   lhs.isActive == rhs.isActive
        }
    }

    @Test("It should work with complex nested models")
    func workWithComplexNestedModels() throws {
        let complexModel = ComplexModel(
            id: UUID(),
            metadata: ["key1": "value1", "key2": "value2"],
            timestamps: [Date(), Date().addingTimeInterval(-3600)],
            isActive: true
        )

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
        }
    }
}
