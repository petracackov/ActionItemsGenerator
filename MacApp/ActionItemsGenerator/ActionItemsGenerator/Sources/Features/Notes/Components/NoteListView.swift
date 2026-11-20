//
//  NoteListView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

struct NoteListView: View {

    let notes: [Note]
    let selectedNote: Note?
    let onSelect: (Note) -> Void

    var body: some View {
        if notes.isEmpty {
            ContentUnavailableView(
                Strings.noNotesTitle,
                systemImage: Icons.note,
                description: Text(Strings.noNotesMessage)
            )
        } else {
            List(notes) { note in
                Button {
                    onSelect(note)
                } label: {
                    NoteRowView(note: note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    
                }
                .buttonStyle(.plain)
                .listRowBackground(rowBackground(for: note))
                .padding(.horizontal)
            }
        }
    }

    private func rowBackground(for note: Note) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(note.id == selectedNote?.id ? AnyShapeStyle(.selection) : AnyShapeStyle(.clear))
            .padding(.horizontal)
    }
}

#Preview {
    NoteListView(notes: Note.samples, selectedNote: Note.samples.first, onSelect: { _ in })
}

#Preview("Empty") {
    NoteListView(notes: [], selectedNote: nil, onSelect: { _ in })
}
