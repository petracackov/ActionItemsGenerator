//
//  ServerError.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

/// Body of every backend error response: `{ "error": { code, message, request_id } }`.
struct ErrorResponse: Decodable {
    let error: ServerError
}

/// The `error` object the backend returns on failure (Documentation/ErrorHandling.md).
struct ServerError: Decodable {
    /// Stable, machine-readable code, e.g. `llm_invalid_output`.
    let code: String
    /// Human-readable. Shown to the user as is.
    let message: String
    /// Matches the backend log entry for debugging.
    let requestId: String?
}
