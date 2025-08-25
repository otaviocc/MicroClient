import Testing
import Foundation
import Combine

@testable import MicroClient

@Suite("NetworkClient Status Publisher Tests")
struct NetworkClientStatusPublisherTests {

    @Test("It should publish running and idle status for successful request")
    func publishRunningAndIdleStatusForSuccessfulRequest() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        mockSession.stubDataToReturn(
            data: Data(),
            response: URLResponse()
        )

        var statusUpdates: [NetworkClientStatus] = []

        let cancellable = client.statusPublisher()
            .sink { status in
                statusUpdates.append(status)
            }

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        _ = try await client.run(request)

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(
            statusUpdates.count == 2,
            "It should publish two status updates"
        )
        #expect(
            statusUpdates[0] == .running,
            "It should first publish running status"
        )
        #expect(
            statusUpdates[1] == .idle,
            "It should then publish idle status"
        )

        cancellable.cancel()
    }

    @Test("It should publish running and idle status even when request fails")
    func publishRunningAndIdleStatusEvenWhenRequestFails() async throws {
        let mockSession = NetworkClientMother.makeMockSession()
        let client = NetworkClientMother.makeNetworkClient(
            session: mockSession
        )

        mockSession.stubDataToThrow(error: URLError(.networkConnectionLost))

        var statusUpdates: [NetworkClientStatus] = []

        let cancellable = client.statusPublisher()
            .sink { status in
                statusUpdates.append(status)
            }

        let request = NetworkRequest<VoidRequest, VoidResponse>(
            path: "/test",
            method: .get
        )

        do {
            _ = try await client.run(request)
        } catch { }

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(
            statusUpdates.count == 2,
            "It should publish two status updates even on failure"
        )
        #expect(
            statusUpdates[0] == .running,
            "It should first publish running status"
        )
        #expect(
            statusUpdates[1] == .idle,
            "It should publish idle status after failure"
        )

        cancellable.cancel()
    }
}
