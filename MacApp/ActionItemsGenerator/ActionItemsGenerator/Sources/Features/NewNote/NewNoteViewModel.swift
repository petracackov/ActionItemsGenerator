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
    var draftText = ""

    var canExtract: Bool {
        !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func extract() {
        // Wired to POST /notes/extract in the next step.
    }
}
