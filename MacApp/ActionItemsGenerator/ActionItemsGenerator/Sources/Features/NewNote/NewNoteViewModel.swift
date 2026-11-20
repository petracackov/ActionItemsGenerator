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
    var draftText = AttributedString()

    var isDraftEmpty: Bool {
        draftText.characters.isEmpty
    }

    var canExtract: Bool {
        !String(draftText.characters).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func extract() {
        // Wired to POST /notes/extract in the next step.
    }
}
