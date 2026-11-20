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
            TextEditor(text: $viewModel.draftText)
                .textInputFormattingControlVisibility(.visible, for: .accessoryBar)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(.quaternary, in: .rect(cornerRadius: 8))
                .overlay(alignment: .topLeading) {
                    if viewModel.isDraftEmpty {
                        Text(Strings.newNotePlaceholder)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
            Button(Strings.extract) {
                viewModel.extract()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!viewModel.canExtract)
        }
        .padding(24)
        .navigationTitle(Strings.newNote)
    }
}

#Preview {
    NewNoteView()
        .frame(width: 600, height: 400)
}
