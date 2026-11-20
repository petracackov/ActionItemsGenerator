//
//  NotesStore.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

import Combine
import Observation

class NotesStore: ObservableObject {

    static let shared = NotesStore()

    @Published private(set) var notes: [Note] = []
    /// The note shown in the detail pane. The only copy of the selection; change it with `select(_:)`.
    @Published private(set) var selectedNote: Note?

    private init() {}

    /// Puts a note at the top of the list.
    func add(_ note: Note) {
        notes.insert(note, at: 0)
    }

    /// Replaces all notes, e.g. with the list loaded from the backend, and sets the selectedNote if it is empty.
    func replaceNotes(with notes: [Note]) {
        self.notes = notes
        if selectedNote == nil {
            selectedNote = notes.first
        }
    }

    func select(_ note: Note?) {
        selectedNote = note
    }
}
