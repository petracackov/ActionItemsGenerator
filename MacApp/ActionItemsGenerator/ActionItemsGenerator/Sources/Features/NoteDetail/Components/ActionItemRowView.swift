//
//  ActionItemRowView.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import SwiftUI

struct ActionItemRowView: View {
    let item: Note.ActionItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: item.done ? Icons.done : Icons.notDone)
                .foregroundStyle(item.done ? Color.accentColor : Color.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)

                metadata
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var metadata: some View {
        HStack(spacing: 12) {
            if let assignee = item.assignee {
                Label(assignee, systemImage: Icons.assignee)
            }

            if let due = item.due {
                Label(due, systemImage: Icons.due)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(spacing: 10) {
        ActionItemRowView(item: Note.samples[0].actionItems[0])
        ActionItemRowView(item: Note.samples[0].actionItems[1])
        ActionItemRowView(item: Note.samples[0].actionItems[2])
    }
}
