---
name: update-agents
description: Add a rule, decision, or note to AGENTS.md. Use when the user says "add to agents", "remember this rule", "note this decision", or invokes /update-agents.
---

# Update AGENTS.md

Add the content given in the arguments (or the user's latest request) to `AGENTS.md` at the project root.

## Steps

1. Read `AGENTS.md`.
2. Pick the section that fits:
   - Requirement → `## Requirements`
   - Tech choice (backend, LLM, libraries) → `## Stack` (replace the matching `TBD` if there is one)
   - How Claude should behave → `## Working rules`
   - Anything else → add a new `##` section with a short, clear name
3. Write it in the same style as the file: one short bullet, imperative, no fluff.
4. Don't duplicate. If a similar line exists, update that line instead.
5. Don't touch `CLAUDE.md`. It only imports `AGENTS.md`.
6. Show the user the added or changed line(s) and which section they went into.
