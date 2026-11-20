//
//  NewNoteView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

struct NewNoteView: View {

    @State private var viewModel = NewNoteViewModel()

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            editorView()
            actionsRow()
        }
        .padding(24)
        .navigationTitle(Strings.newNote)
    }

    private func editorView() -> some View {
        TextEditor(text: $viewModel.draftText)
            .font(.body.monospaced())
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(.quaternary, in: .rect(cornerRadius: 8))
            .overlay(alignment: .topLeading) {
                if viewModel.isDraftEmpty {
                    Text(Strings.newNotePlaceholder)
                        .font(.body.monospaced())
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            .disabled(viewModel.isExtracting)
    }

    private func actionsRow() -> some View {
        HStack(spacing: 12) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Spacer()

            if viewModel.isExtracting {
                ProgressView()
                    .controlSize(.small)
            }

            Button(Strings.extract) {
                viewModel.extract()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!viewModel.canExtract)
        }
    }
}

#Preview {
    NewNoteView()
        .frame(width: 600, height: 400)
}
