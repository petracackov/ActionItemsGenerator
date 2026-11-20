//
//  NoteDetailView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

/// Shows a note's action items and its raw text as submitted.
struct NoteDetailView: View {
    @State private var viewModel: NoteDetailViewModel

    init(note: Note) {
        _viewModel = State(initialValue: NoteDetailViewModel(note: note))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(viewModel.note.createdAtString)
                    .foregroundStyle(.secondary)
                actionItems
                originalNotes
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(viewModel.note.title ?? Strings.untitledNote)
    }

    private var actionItems: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.actionItems)
                .font(.title3.bold())
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            if viewModel.note.actionItems.isEmpty {
                Text(Strings.noActionItems)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.note.actionItems) { item in
                    ActionItemRowView(item: item) {
                        viewModel.toggleDone(for: item)
                    }
                }
            }
        }
    }

    private var originalNotes: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.originalNotes)
                .font(.title3.bold())
            Text(viewModel.note.text)
                .font(.body.monospaced())
                .textSelection(.enabled)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary, in: .rect(cornerRadius: 8))
        }
    }
}

#Preview {
    NoteDetailView(note: Note.samples[0])
        .frame(width: 600, height: 600)
}
