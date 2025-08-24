import Testing
import Foundation
@testable import MicroClient

@Suite("NetworkRequest Query Items Tests")
struct NetworkRequestQueryItemsTests {

    @Test("It should store multiple query items")
    func storeMultipleQueryItems() {
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "sort", value: "name")
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get,
            queryItems: queryItems
        )

        #expect(
            request.queryItems.count == 3,
            "It should store all query items"
        )
        #expect(
            request.queryItems == queryItems,
            "It should store the exact query items"
        )
    }

    @Test("It should handle query items with nil values")
    func handleQueryItemsWithNilValues() {
        let queryItems = [
            URLQueryItem(name: "required", value: "value"),
            URLQueryItem(name: "optional", value: nil)
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get,
            queryItems: queryItems
        )

        #expect(
            request.queryItems.count == 2,
            "It should store all query items including ones with nil values"
        )
        #expect(
            request.queryItems[1].value == nil,
            "It should preserve nil values in query items"
        )
    }
}
