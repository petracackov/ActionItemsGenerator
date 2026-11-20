//
//  NoteDetailViewModel.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

import Combine
import Foundation
import Observation

@Observable
class NoteDetailViewModel {

    private let notesStore = NotesStore.shared

    /// Kept up to date from the store, so changes like marking an item done show right away.
    private(set) var note: Note
    private(set) var errorMessage: String?

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init(note: Note) {
        self.note = note
        subscribeToChanges()
    }

    func toggleDone(for item: Note.ActionItem) {
        errorMessage = nil
        Task {
            do throws(APIError) {
                let request = APIRequest(endpoint: .updateItem(id: item.id, done: !item.done))
                let updatedItem = try await APIManager.shared.performRequest(request, dataType: Note.ActionItem.self)
                notesStore.replaceItem(updatedItem, in: note)
            } catch {
                errorMessage = error.message
            }
        }
    }

    // MARK: - Private

    private func subscribeToChanges() {
        notesStore.$notes
            .sink { [weak self] notes in
                self?.updateNote(from: notes)
            }
            .store(in: &cancellables)
    }

    /// Takes the store's latest version of this note.
    private func updateNote(from notes: [Note]) {
        guard let updatedNote = notes.first(where: { $0.id == note.id }) else {
            return
        }
        note = updatedNote
    }
}
