//
//  APIRequest.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

import Foundation

/// One call to the backend. Endpoints match Documentation/API.md.
struct APIRequest {

    // TODO: Temporary, for local testing only. We have no hosted server yet, so this points at the
    // backend running on this Mac. Replace with the real server URL (ideally from config) once it's deployed.
    private static let baseURL = "http://127.0.0.1:8000"

    let endpoint: Endpoint

    func urlRequest() throws(APIError) -> URLRequest {
        guard let url = URL(string: APIRequest.baseURL + endpoint.path) else {
            throw .invalidRequest
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try endpoint.body()
        endpoint.headers.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }
        return request
    }

    enum Endpoint {
        case notes
        case extract(text: String)
        case updateItem(id: UUID, done: Bool)

        var method: Method {
            switch self {
            case .notes: .get
            case .extract: .post
            case .updateItem: .patch
            }
        }

        var path: String {
            switch self {
            case .notes: "/notes"
            case .extract: "/notes/extract"
            case .updateItem(let id, _): "/items/\(id.uuidString)"
            }
        }

        /// Header field -> value.
        var headers: [String: String] {
            switch self {
            case .notes: [:]
            case .extract, .updateItem: [Header.contentType: Header.json]
            }
        }

        func body() throws(APIError) -> Data? {
            do {
                switch self {
                case .notes:
                    return nil
                case .extract(let text):
                    return try JSONEncoder().encode(ExtractBody(text: text))
                case .updateItem(_, let done):
                    return try JSONEncoder().encode(UpdateItemBody(done: done))
                }
            } catch {
                throw .invalidRequest
            }
        }

        private struct ExtractBody: Encodable {
            let text: String
        }

        private struct UpdateItemBody: Encodable {
            let done: Bool
        }

        private enum Header {
            static let contentType = "Content-Type"
            static let json = "application/json"
        }
    }

    enum Method: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
    }

}
