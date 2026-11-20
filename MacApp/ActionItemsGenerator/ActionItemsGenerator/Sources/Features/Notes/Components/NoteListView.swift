//
//  NoteListView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

struct NoteListView: View {

    let notes: [Note]
    @Binding var selection: SelectionType?

    var body: some View {
        if notes.isEmpty {
            ContentUnavailableView(
                Strings.noNotesTitle,
                systemImage: Icons.note,
                description: Text(Strings.noNotesMessage)
            )
        } else {
            List(notes, selection: $selection) { note in
                NoteRowView(note: note)
                    .tag(SelectionType.note(note))
            }
        }
    }
}

#Preview {
    NoteListView(notes: Note.samples, selection: .constant(nil))
}

#Preview("Empty") {
    NoteListView(notes: [], selection: .constant(nil))
}
