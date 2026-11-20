//
//  NotesViewModel.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import Combine
import Foundation
import Observation

@Observable
class NotesViewModel {

    private var notesStore = NotesStore.shared

    private(set) var notes: [Note] = []
    private(set) var selectedNote: Note?

    /// Whether the detail pane shows the new-note editor. Local UI state, separate from the selection.
    private(set) var isCreatingNote = false

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init() {
        subscribeToChanges()
    }

    func startNewNote() {
        notesStore.select(nil)
        isCreatingNote = true
    }

    func select(_ note: Note) {
        notesStore.select(note)
    }

    // MARK: - Private

    private func subscribeToChanges() {
        notesStore.$notes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notes in
                self?.update(notes)
            }
            .store(in: &cancellables)

        notesStore.$selectedNote
            .sink { [weak self] note in
                self?.updateSelectedNote(note)
            }
            .store(in: &cancellables)
    }

    /// Selecting a note (a click in the list, or a just-created note) leaves the new-note editor.
    private func updateSelectedNote(_ note: Note?) {
        selectedNote = note
        guard note != nil else {
            return
        }
        isCreatingNote = false
    }

    /// Takes the store's latest notes.
    @MainActor
    private func update(_ newNotes: [Note]) {
        notes = newNotes
    }
}
