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
    var draftText = AttributedString()

    private(set) var isExtracting = false
    private(set) var errorMessage: String?

    var isDraftEmpty: Bool {
        draftText.characters.isEmpty
    }

    var canExtract: Bool {
        !isExtracting && !plainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Sends the draft to `POST /notes/extract` and adds the saved note to `NotesStore`.
    func extract() {
        errorMessage = nil
        isExtracting = true
        Task {
            defer { isExtracting = false }
            do throws(APIError) {
                let request = APIRequest(endpoint: .extract(text: plainText))
                let note = try await APIManager.shared.performRequest(request, dataType: Note.self)
                notesStore.add(note)
                notesStore.select(note)
            } catch {
                errorMessage = error.message
            }
        }
    }

    // MARK: - Private

    /// The backend takes plain text, so rich text formatting is dropped here.
    private var plainText: String {
        String(draftText.characters)
    }
}
