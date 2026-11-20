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
            sidebar
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
        .frame(minWidth: 720, minHeight: 460)
    }

    @ViewBuilder
    private var sidebar: some View {
        switch viewModel.loadState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let error):
            ContentUnavailableView {
                Label(Strings.loadNotesErrorTitle, systemImage: Icons.warning)
            } description: {
                Text(error.message)
            } actions: {
                Button(Strings.tryAgain, action: viewModel.loadNotes)
            }
        case .loaded:
            NoteListView(
                notes: viewModel.notes,
                selectedNote: viewModel.selectedNote,
                onSelect: viewModel.select
            )
        }
    }

    @ViewBuilder
    private var detail: some View {
        if viewModel.isCreatingNote {
            NewNoteView()
        } else if let note = viewModel.selectedNote {
            // New identity per note, so the detail gets a fresh ViewModel for each note.
            NoteDetailView(note: note)
                .id(note.id)
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
