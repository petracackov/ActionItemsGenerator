//
//  NotesSplitView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

struct NotesSplitView: View {

    @State private var viewModel: NotesViewModel

    /// `notes` is only for previews. The app starts empty.
    init(notes: [Note] = []) {
        _viewModel = .init(initialValue: NotesViewModel(notes: notes))
    }

    var body: some View {
        NavigationSplitView {
            NoteListView(notes: viewModel.notes, selection: $viewModel.selection)
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
        switch viewModel.selection {
        case .note(let note):
            NoteDetailView(note: note)
        case .newNote:
            NewNoteView()
        case nil:
            ContentUnavailableView(
                Strings.noSelectionTitle,
                systemImage: Icons.note,
                description: Text(Strings.noSelectionMessage)
            )
        }
    }
}

#Preview {
    NotesSplitView(notes: Note.samples)
}

#Preview("Empty") {
    NotesSplitView()
}
