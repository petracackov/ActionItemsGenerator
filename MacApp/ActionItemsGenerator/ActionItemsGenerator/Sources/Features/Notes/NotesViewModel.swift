//
//  NotesViewModel.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import Foundation
import Observation

@Observable
class NotesViewModel {

    var notes: [Note]
    var selection: SelectionType?

    init(notes: [Note] = []) {
        self.notes = notes
        if let firstNote = notes.first {
            selection = .note(firstNote)
        }
    }

    func startNewNote() {
        selection = .newNote
    }
}
