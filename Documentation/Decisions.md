# Decisions

Key technical decisions: what we chose, the alternatives, and why. Overview: [Architecture.md](Architecture.md). Full tool and library list: [Stack.md](Stack.md).

---

## 1. Backend: Python + FastAPI

**Chosen:** Python with FastAPI.

**Alternatives:**
- Swift + Vapor: same language as the app, and models could be shared. But more setup code, slower builds, and fewer LLM examples.
- TypeScript + Node: common, but no advantage here.

**Why:** least code for a small JSON API. Pydantic validates the LLM's JSON against a schema, which directly covers "reject unusable output". API docs are auto-generated at `/docs`.

**Trade-off:** a new language for the author (an iOS developer).

---

## 2. LLM: Groq

**Chosen:** Groq free tier.

**Alternatives:**
- Google AI Studio (Gemini): free, strong JSON-schema support, but usually slower (1–3s).
- Ollama (local): no key needed, but the reviewer has to download a multi-GB model, and it's likely too slow on a laptop.

**Why:** free, and very fast inference fits the under-2-seconds requirement. It supports JSON output mode.

**Trade-off:** free-tier rate limits, and it's an external dependency that can be down. Both are handled as errors.

---

## 3. Storage: SQLite via SQLModel

**Chosen:** SQLite file (`data.db`), accessed through SQLModel (an ORM: tables as Python classes).

**Alternatives:**
- In memory: lost on restart, so it fails "persisted".
- JSON file: risk of corruption and concurrent overwrites, and no transactions.
- PostgreSQL: a separate server to install or run. Overkill for v1.

**Why:** one file with nothing to install, since it's built into Python. Transactions give "save note + items, or nothing". The ORM means switching to Postgres later only changes the connection string.

**Trade-off:** not suited to many concurrent users. That's fine for v1 and is addressed in v2.

---

## 4. The backend owns the data, not the Mac app

**Chosen:** the backend stores notes and items. The Mac app only displays them and sends changes.

**Alternative:** store data locally in the Mac app (SwiftData), with the backend only extracting.

**Why:**
- The assignment says the backend "saves" the items.
- Validation and saving happen in one step on the server, so bad data can't slip in between.
- The note, items and logs live in one place for debugging and auditing.
- The upgrade path to a shared, hosted v2 is a config change, not a data migration from every user's Mac.

**Trade-off:** no offline access to past items.

---

## 5. No authentication in v1

**Chosen:** no login in v1. A `current_user()` dependency returns a fixed `local-user`, and every note still stores `created_by`.

**Alternatives:**
- Supabase or Firebase Auth now: real per-user access, but costs about 1–1.5h of the timebox and adds setup (project keys) for the reviewer.
- A device UUID sent as a header: looks like auth but can be faked. Rejected as misleading.
- Custom username and password: the most work and the easiest to get wrong.

**Why:** not required by the assignment, and the time is better spent on failure handling. The design is ready for it: auth lives in one function, and the data model already has `created_by`.

**Trade-off:** in v1 everyone using the same backend sees the same notes. v2 adds Supabase Auth (see [Architecture.md → v2](Architecture.md#v2-post-mvp-auth--hosted-database)).

---

## 6. Run locally, no hosting

**Chosen:** the backend runs on the same Mac as the app (`localhost:8000`), started with one setup command.

**Alternative:** host the backend (Render, Fly.io, etc.).

**Why:** not required, zero cost, and the reviewer controls everything. The backend URL is read from config, so hosting later is a config change.

**Trade-off:** no shared team use until it's hosted (v2).

---

## 7. Error handling defaults

Open questions for the product owner. Until answered, these defaults apply (details in [ErrorHandling.md](ErrorHandling.md)):

| Question | Default | Why |
|---|---|---|
| Is under 2s a hard limit or a target? | **Target.** 5s timeout, duration logged, over 2s logged as a warning | A 2s hard cut would fail requests that are only slightly slow. Logging shows how often we miss it. |
| Retry on unusable output? | **No retry** | A retry roughly doubles the time and breaks the 2s goal. The user can resubmit. |
| Due dates: as written or converted? | **As written** ("by Friday") | Converting relative dates is guesswork and could create wrong data. |
| No action items found: save the note? | **Save it** with an empty list | It's a valid result, and it keeps the audit trail complete. |
