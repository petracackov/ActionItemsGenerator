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

    /// Items with a `PATCH` running. At most one request per item at a time.
    @ObservationIgnored private var itemsBeingSaved = Set<Note.ActionItem.ID>()
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init(note: Note) {
        self.note = note
        subscribeToChanges()
    }

    /// Flips `done` right away, then saves it. Clicks while a save is running only change the
    /// local value; when the save finishes, one more request is sent if the value changed since.
    func toggleDone(for item: Note.ActionItem) {
        errorMessage = nil
        let isSaving = itemsBeingSaved.contains(item.id)

        var toggledItem = item
        toggledItem.done.toggle()
        notesStore.replaceItem(toggledItem, in: note)

        guard !isSaving else {
            return
        }

        save(toggledItem)
    }

    // MARK: - Private

    /// Sends `item.done` to the backend. `item` is the latest local version of the item.
    private func save(_ item: Note.ActionItem) {
        itemsBeingSaved.insert(item.id)

        Task {
            do throws(APIError) {
                let request = APIRequest(endpoint: .updateItem(id: item.id, done: item.done))
                let savedItem = try await APIManager.shared.performRequest(request, dataType: Note.ActionItem.self)
                itemsBeingSaved.remove(item.id)
                saveAgainIfChanged(savedItem)
            } catch {
                itemsBeingSaved.remove(item.id)
                undoUnsavedChange(item)
                errorMessage = error.message
            }
        }
    }

    /// The user clicked again while the save was running: send the latest value.
    private func saveAgainIfChanged(_ savedItem: Note.ActionItem) {
        guard let currentItem = note.actionItems.first(where: { $0.id == savedItem.id }),
              currentItem.done != savedItem.done else {
            return
        }
        save(currentItem)
    }

    /// Puts the item back to what the backend has. A save is only sent when the value differs
    /// from the backend's, so after a failed save of `item` the backend still has `!item.done`.
    private func undoUnsavedChange(_ item: Note.ActionItem) {
        var restoredItem = item
        restoredItem.done.toggle()
        notesStore.replaceItem(restoredItem, in: note)
    }

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
