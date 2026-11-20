//
//  NotesResponse.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

/// Response of `GET /notes`.
struct NotesResponse: Decodable {
    let notes: [Note]
}
