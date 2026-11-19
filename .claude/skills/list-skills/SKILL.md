---
name: list-skills
description: List all skills created for this project. Use when the user asks "what skills do we have", "list skills", or invokes /list-skills.
---

# List project skills

1. Find every `.claude/skills/*/SKILL.md` in the project root.
2. From each file's frontmatter, read `name` and `description`.
3. Output a table, sorted by name:

| Command | What it does |
|---|---|
| `/<name>` | one-line summary of `description` |

No extra commentary.
