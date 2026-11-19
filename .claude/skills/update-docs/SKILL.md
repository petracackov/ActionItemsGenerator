---
name: update-docs
description: Check whether the documentation in Documentation/ needs to be added or updated for recent work (features, stack, libraries, decisions), and propose changes for approval. Use when the user says "update docs", "document this", or invokes /update-docs.
---

# Update documentation

Decide whether the docs need a change, explain what you'd change, and **write nothing without the user's approval.**

## Steps

1. **Scope.** If the arguments name a feature or area, check only that. Otherwise, look at what changed recently in this conversation (code, dependencies, decisions).
2. **Read current docs.** Read the relevant files in `Documentation/` (and `README.md` if run instructions changed).
3. **Decide if it's needed.** For each candidate item, check:
   - **Complete?** Is the feature, library or decision finished and stable? If it's still in progress, skip it.
   - **Already covered?** Do the docs already describe it correctly? If so, skip it.
   - **Outdated?** Do the docs describe something that has changed or been removed? If so, propose an update.
   - **Useful to a reviewer?** Would a reviewer or future dev need this? Skip trivial details.
4. **If nothing is needed:** say so in one line, with the reason (for example "auth still in progress" or "docs already up to date"). Stop.
5. **Propose.** For each change, show:
   - **File:** the path (new or existing).
   - **What:** add, update or remove.
   - **Why:** one line.
   - **Content:** a short outline of what will be written.
6. **Ask for approval** (approve, edit or reject), per item if there are several. Stop and wait.
7. **On approval only:** write the changes. Follow the doc rules in `AGENTS.md`: all docs live in `Documentation/`, and the README holds only what the assignment requires. Show what was written.
