//
//  NoteRowView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 20. 11. 26.
//

import SwiftUI

/// Keep this a separate View struct: building the row in a `some View` helper
/// function inside `NoteListView` crashes the Xcode preview of the List on macOS.
/// Only a `List` problem: the same helper inside a `VStack` previews fine.
struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title ?? Strings.untitledNote)
                .font(.headline)
                .lineLimit(1)
            Text(note.createdAtString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NoteRowView(note: Note.samples[0])
        .padding()
}
