//
//  Note.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 19. 11. 26.
//

import Foundation

/// A submitted note with the action items extracted from it. Matches `Note` in Documentation/API.md.
struct Note: Codable, Identifiable, Hashable {
    let id: UUID
    /// The raw notes exactly as submitted.
    let text: String
    let createdAt: Date
    var actionItems: [ActionItem]

    struct ActionItem: Codable, Identifiable, Hashable {
        let id: UUID
        let text: String
        let assignee: String?
        let due: String?
        var done: Bool
    }

    /// First non-empty line of the raw notes.
    var title: String? {
        text.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty }
    }

    /// `createdAt` formatted for display, e.g. "20 Nov 2026, 11:30".
    var createdAtString: String {
        DateHelper.shared.fullDateString(date: createdAt)
    }
}

#if DEBUG
extension Note {
    static let samples: [Note] = [
        Note(
            id: UUID(),
            text: """
            weekly sync tues

            - deploy went out friday, mostly fine. two customers hit the timeout thing
              again. Ana is going to look at the retry logic
            - billing page redesign -- still blocked on copy from marketing. Marko is
              chasing, said he'd have an answer by Friday
            - Ana raised that the staging db hasn't been reset since June. no owner on this yet
            """,
            createdAt: .now,
            actionItems: [
                ActionItem(id: UUID(), text: "Look into the retry logic causing customer timeouts", assignee: "Ana", due: nil, done: false),
                ActionItem(id: UUID(), text: "Get an answer from marketing on billing page copy", assignee: "Marko", due: "Friday", done: true),
                ActionItem(id: UUID(), text: "Reset the staging database", assignee: nil, due: nil, done: false),
            ]
        ),
        Note(
            id: UUID(),
            text: """
            call w/ Nordwind, 40 min, me + Ana

            they're happy overall. they asked about SSO again. I said Q1 which I'm not
            sure is true -- need to check with product.
            """,
            createdAt: .now.addingTimeInterval(-86_400),
            actionItems: [
                ActionItem(id: UUID(), text: "Check the SSO timeline with product", assignee: "me", due: nil, done: false),
            ]
        ),
        Note(
            id: UUID(),
            text: "quick chat, nothing to do",
            createdAt: .now.addingTimeInterval(-172_800),
            actionItems: []
        ),
    ]
}
#endif
