//
//  APIError.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

enum APIError: Error {
    /// The backend isn't running or the network failed.
    case cannotReachServer
    /// The backend returned an error body.
    case server(ServerError)
    /// The response wasn't HTTP or didn't decode into the expected model.
    case invalidResponse
    /// The request couldn't be built (bad URL or body).
    case invalidRequest

    /// Text to show the user.
    var message: String {
        switch self {
        case .cannotReachServer:
            Strings.cannotReachServer
        case .server(let serverError):
            serverError.message
        case .invalidResponse, .invalidRequest:
            Strings.unexpectedError
        }
    }
}
