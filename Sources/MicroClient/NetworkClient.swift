// MIT License
//
// Copyright (c) 2026 Otávio C.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// The network client interface.
public protocol NetworkClientProtocol: Sendable {

    /// Performs the network request.
    ///
    /// - Parameter networkRequest: The network request to perform.
    /// - Returns: The network response.
    func run<ResponseModel>(
        _ networkRequest: NetworkRequest<some Any, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel>
}

/// The network client, conforming to the `NetworkClientProtocol` protocol.
public actor NetworkClient: NetworkClientProtocol {

    // MARK: - Properties

    private let configuration: NetworkConfiguration

    // MARK: - Life cycle

    public init(
        configuration: NetworkConfiguration
    ) {
        self.configuration = configuration
    }

    // MARK: - Public

    public func run<ResponseModel>(
        _ networkRequest: NetworkRequest<some Any, ResponseModel>
    ) async throws -> NetworkResponse<ResponseModel> {
        let retryStrategy = networkRequest.retryStrategy ?? configuration.retryStrategy
        var lastError: Error?

        for attempt in 0...retryStrategy.count {
            try Task.checkCancellation()

            do {
                return try await performRequest(networkRequest, attempt: attempt)
            } catch {
                lastError = error
            }
        }

        throw lastError ?? NetworkClientError.unknown(nil)
    }

    // MARK: - Private

    // swiftlint:disable function_body_length

    private func performRequest<ResponseModel>(
        _ networkRequest: NetworkRequest<some Any, ResponseModel>,
        attempt: Int
    ) async throws -> NetworkResponse<ResponseModel> {
        if attempt > 0 {
            log(.warning, "Retrying request... Attempt \(attempt)")
        }

        var urlRequest: URLRequest
        do {
            urlRequest = try URLRequest.makeURLRequest(
                configuration: configuration,
                networkRequest: networkRequest
            )
        } catch let error as EncodingError {
            log(.error, "Request encoding error: \(error.localizedDescription)")
            throw NetworkClientError.encodingError(error)
        } catch {
            log(.error, "Malformed URL error.")
            throw NetworkClientError.malformedURL
        }

        let interceptors = networkRequest.interceptors ?? configuration.interceptors

        do {
            for interceptor in interceptors {
                urlRequest = try await interceptor.intercept(urlRequest)
            }
        } catch {
            log(.error, "Interceptor error: \(error.localizedDescription)")
            throw NetworkClientError.interceptorError(error)
        }

        log(.info, "Request: \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "")")
        log(.debug, "Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await configuration.session.data(
                for: urlRequest,
                delegate: nil
            )
        } catch let error as CancellationError {
            throw error
        } catch {
            log(.error, "Transport error: \(error.localizedDescription)")
            throw NetworkClientError.transportError(error)
        }

        if let httpResponse = response as? HTTPURLResponse {
            log(
                .info,
                "Response: \(httpResponse.statusCode) \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "")"
            )
            log(.debug, "Response headers: \(httpResponse.allHeaderFields)")

            guard (200...299).contains(httpResponse.statusCode) else {
                log(.error, "Unacceptable status code: \(httpResponse.statusCode)")
                throw NetworkClientError.unacceptableStatusCode(
                    statusCode: httpResponse.statusCode,
                    response: httpResponse,
                    data: data
                )
            }
        }

        let value: ResponseModel
        do {
            value = try networkRequest.decode(
                data: data,
                defaultDecoder: configuration.defaultDecoder
            )
            log(.debug, "Response data: \(String(data: data, encoding: .utf8) ?? "")")
        } catch let error as DecodingError {
            log(.error, "Response decoding error: \(error.localizedDescription)")
            throw NetworkClientError.decodingError(error)
        } catch {
            log(.error, "Unknown error during decoding: \(error.localizedDescription)")
            throw NetworkClientError.unknown(error)
        }

        var networkResponse = NetworkResponse(
            value: value,
            response: response
        )

        let responseInterceptors = networkRequest.responseInterceptors ?? configuration.responseInterceptors

        do {
            for interceptor in responseInterceptors {
                networkResponse = try await interceptor.intercept(networkResponse, data)
            }
        } catch {
            log(.error, "Response interceptor error: \(error.localizedDescription)")
            throw NetworkClientError.responseInterceptorError(error)
        }

        try Task.checkCancellation()

        return networkResponse
    }

    // swiftlint:enable function_body_length

    private func log(
        _ level: NetworkLogLevel,
        _ message: String
    ) {
        guard
            let logger = configuration.logger,
            level >= configuration.logLevel else { return }

        logger.log(level: level, message: message)
    }
}
