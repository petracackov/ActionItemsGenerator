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

    private(set) var loadState: LoadState = .loading

    /// True while notes are loading, to disable the reload button.
    var isLoading: Bool {
        switch loadState {
        case .loading:
            true
        case .failed, .loaded:
            false
        }
    }

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init() {
        subscribeToChanges()
        loadNotes()
    }

    func loadNotes() {
        setState(.loading)

        Task {
            do throws(APIError) {
                let request = APIRequest(endpoint: .notes)
                let response = try await APIManager.shared.performRequest(request, dataType: NotesResponse.self)
                notesStore.replaceNotes(with: response.notes)
                setState(.loaded)
            } catch {
                setState(.failed(error))
            }
        }
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

    private func setState(_ state: LoadState) {
        self.loadState = state
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
    private func update(_ newNotes: [Note]) {
        notes = newNotes
    }
}
