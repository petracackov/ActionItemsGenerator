//
//  APIManager.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

import Foundation

/// Sends `APIRequest`s to the backend and decodes the JSON response.
/// Every failure is turned into an `APIError`.
class APIManager {

    static let shared = APIManager()

    /// Matches the backend's snake_case keys and ISO 8601 dates (Documentation/API.md).
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func performRequest<Model: Decodable>(_ apiRequest: APIRequest, dataType: Model.Type) async throws(APIError) -> Model {
        let urlRequest = try apiRequest.urlRequest()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw .cannotReachServer
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw serverError(from: data)
        }

        do {
            return try decoder.decode(Model.self, from: data)
        } catch {
            throw .invalidResponse
        }
    }

    // MARK: - Private

    /// Reads the backend's `{ "error": { code, message, request_id } }` body (Documentation/ErrorHandling.md).
    private func serverError(from data: Data) -> APIError {
        guard let body = try? decoder.decode(ErrorResponse.self, from: data) else {
            return .invalidResponse
        }
        return .server(body.error)
    }

}
