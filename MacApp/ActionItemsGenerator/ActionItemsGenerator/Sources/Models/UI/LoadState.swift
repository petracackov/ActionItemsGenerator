//
//  LoadState.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

/// State of loading data from the backend.
enum LoadState {
    case loading
    case failed(APIError)
    case loaded
}
