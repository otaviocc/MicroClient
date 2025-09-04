actor MockInterceptorStorage {

    // MARK: - Properties

    var callOrder: [String] = []

    // MARK: - Public

    func recordCall(id: String) {
        callOrder.append(id)
    }
}
