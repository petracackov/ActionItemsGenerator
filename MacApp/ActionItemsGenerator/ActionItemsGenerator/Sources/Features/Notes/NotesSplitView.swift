//
//  NotesSplitView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

struct NotesSplitView: View {

    @State private var viewModel = NotesViewModel()

    var body: some View {
        NavigationSplitView {
            NoteListView(
                notes: viewModel.notes,
                selectedNote: viewModel.selectedNote,
                onSelect: viewModel.select
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 280)
            .toolbar {
                ToolbarItem {
                    Button(
                        Strings.newNote,
                        systemImage: Icons.add,
                        action: viewModel.startNewNote
                    )
                }
            }
        } detail: {
            detail
        }
    }

    @ViewBuilder
    private var detail: some View {
        if viewModel.isCreatingNote {
            NewNoteView()
        } else if let note = viewModel.selectedNote {
            NoteDetailView(note: note)
        } else {
            ContentUnavailableView(
                Strings.noSelectionTitle,
                systemImage: Icons.note,
                description: Text(Strings.noSelectionMessage)
            )
        }
    }
}

#Preview {
    let _ = Note.samples.reversed().forEach(NotesStore.shared.add)
    NotesSplitView()
}

#Preview("Empty") {
    NotesSplitView()
}
