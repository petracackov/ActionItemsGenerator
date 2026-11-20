# Action Item Extractor

A macOS app where you paste raw meeting notes. A backend sends them to an LLM and returns structured action items. The items are saved and you can mark them done.

- Assignment: [Documentation/Assignment.md](Documentation/Assignment.md)

## 1. How to run the project

See [Documentation/Setup.md](Documentation/Setup.md).

## 2. What I would do differently with a full week

- **Build v2.** Add login (Supabase Auth) so each user sees only their own notes, move from the local SQLite file to a hosted Postgres database, and deploy the backend to a server instead of running it on `localhost`. v1 is already shaped for this: auth lives in one function and every note stores `created_by`. See [Architecture.md → v2](Documentation/Architecture.md#v2-post-mvp-auth--hosted-database).
- **A more custom Mac app.** The UI sticks to stock system components to save time. With more time I'd give it its own look, with custom styles, colors and small animations, so it feels less like a default template and more fun to use.
- **Understand the backend more deeply.** I'm an iOS developer and Python/FastAPI was new to me, so I leaned on AI for the backend. With a week I'd go through it properly: how each piece works, why it's built that way, and where it could break.
- **Reload a single note.** The reload button refetches every note, because the backend only has `GET /notes`. I'd add `GET /notes/{id}` so the app can refresh just the note you're looking at.
- **Pagination for notes.** `GET /notes` returns every note at once. That's fine for a demo, but it gets slow as notes pile up. I'd add paging on the backend and load more as you scroll in the app.
- **Due as a real date.** `due` is stored as written ("Friday", "next week"). I'd have the LLM resolve it to an actual date relative to when the note was written, and store it as an ISO date next to the original wording. That would allow sorting, overdue highlighting and a proper date display in the app.

## 3. One decision I'm not fully confident about

_TBD_

## 4. One thing I deliberately skipped, and why

_TBD_
