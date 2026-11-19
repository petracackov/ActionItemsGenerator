# Stack

Tools and libraries used. Reasons for the main choices: [Decisions.md](Decisions.md).

## Backend

| What | Choice | Purpose |
|---|---|---|
| Language | Python 3.12 | |
| Package manager | uv | Installs Python and dependencies with one command |
| Web framework | FastAPI | Routes, request validation, auto docs at `/docs` |
| Server | Uvicorn | Runs the FastAPI app on `127.0.0.1:8000` |
| Validation | Pydantic | Schema classes for requests and LLM output |
| DB / ORM | SQLModel + SQLite | Tables as Python classes, stored in one file (`data.db`) |
| LLM client | `groq` (official SDK) | Calls Groq with a timeout. Strict Structured Outputs if the model supports it, otherwise JSON mode. Model chosen by measured latency, set in `.env` |
| Config | `python-dotenv` | Loads the Groq key and settings from `.env` |
| Tests | pytest | Failure cases, with Groq mocked |

## Mac app

| What | Choice |
|---|---|
| UI | SwiftUI, macOS 14+ |
| Networking | `URLSession` + `Codable` |
| State | `@Observable` |
| Tests | Swift Testing / XCTest |

No third-party Swift packages.

## External services

| Service | Purpose |
|---|---|
| Groq API | LLM extraction (free API key required) |

## v2 (post-MVP) additions

| What | Choice |
|---|---|
| Auth + DB | Supabase (Auth + Postgres) |
| Mac app | Supabase Swift SDK (sign-in) |
