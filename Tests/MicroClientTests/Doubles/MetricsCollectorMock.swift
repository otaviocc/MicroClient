import Foundation

@testable import MicroClient

final class MetricsCollectorMock: MetricsCollector, @unchecked Sendable {

    // MARK: - Properties

    var collectCalled = false
    var collectCallCount = 0
    var lastMetrics: ResponseMetrics?
    var collectedMetrics: [ResponseMetrics] = []

    // MARK: - Public

    func collect(_ metrics: ResponseMetrics) async {
        collectCalled = true
        collectCallCount += 1
        lastMetrics = metrics
        collectedMetrics.append(metrics)
    }
}
