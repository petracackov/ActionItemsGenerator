//
//  NewNoteViewModel.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

import Foundation
import Observation

@Observable
class NewNoteViewModel {

    private let notesStore = NotesStore.shared
    /// Plain text. Markdown typed here (e.g. `**bold**`) is sent as is and rendered in the note detail.
    var draftText = ""

    private(set) var isExtracting = false
    private(set) var errorMessage: String?

    var isDraftEmpty: Bool {
        draftText.isEmpty
    }

    var canExtract: Bool {
        !isExtracting && !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Sends the draft to `POST /notes/extract` and adds the saved note to `NotesStore`.
    func extract() {
        errorMessage = nil
        isExtracting = true
        Task {
            defer { isExtracting = false }
            do throws(APIError) {
                let request = APIRequest(endpoint: .extract(text: draftText))
                let note = try await APIManager.shared.performRequest(request, dataType: Note.self)
                notesStore.add(note)
                notesStore.select(note)
            } catch {
                errorMessage = error.message
            }
        }
    }
}
