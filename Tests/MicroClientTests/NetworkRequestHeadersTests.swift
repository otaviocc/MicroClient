import Testing
import Foundation
@testable import MicroClient

@Suite("NetworkRequest Headers Tests")
struct NetworkRequestHeadersTests {

    @Test("It should store additional headers")
    func storeAdditionalHeaders() {
        let headers = [
            "Authorization": "Bearer token",
            "Content-Type": "application/json",
            "X-Custom-Header": "custom-value"
        ]

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .post,
            additionalHeaders: headers
        )

        #expect(
            request.additionalHeaders == headers,
            "It should store the additional headers"
        )
    }

    @Test("It should handle nil additional headers")
    func handleNilAdditionalHeaders() {
        let request = NetworkRequest<VoidRequest, VoidResponse>(
            method: .get,
            additionalHeaders: nil
        )

        #expect(
            request.additionalHeaders == nil,
            "It should handle nil additional headers"
        )
    }
}
