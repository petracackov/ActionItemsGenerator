# Action Items Generator

Take-home test project for a job application. Timebox: 4 hours (graded on what's there, not how much). Stack is free choice.

## Requirements

- See [`Documentation/Assignment.md`](Documentation/Assignment.md). Read it before planning or building anything.

## Stack

- See [`Documentation/Stack.md`](Documentation/Stack.md), [`Documentation/Architecture.md`](Documentation/Architecture.md) and [`Documentation/Decisions.md`](Documentation/Decisions.md).

## Working rules

- **Small steps only.** Never do a big chunk of work in one go. After each meaningful step, stop and ask the user to review. Continue only after explicit permission.
- **Backend:** the user is new to backend development. Explain what you're doing and why (concepts, tools, commands) more often and in plain terms.
- **Swift / macOS:** the user is a senior iOS engineer. No long explanations; only call out non-obvious decisions.
- **General:** no fluff. Short, correct, to the point.
- **Docs location:** put all documentation and plans in the `Documentation/` folder. `AGENTS.md` holds only rules and pointers to those files, never documentation content. Exception: the root `README.md`, which holds only what the assignment requires. Add nothing extra unless the user asks.
- **Document as you go:** document features, stack, libraries and key decisions in `Documentation/`. Always ask the user before adding or changing any documentation.

## Git

- **Branches, no PRs:** do each step on a `feature/<name>` branch, then merge it into `main` directly. No pull requests (single developer).
- **Keep branches:** never delete a branch after merging it.

## Project skills

- Skills live in `.claude/skills/<name>/SKILL.md`. Run `/list-skills` to see them all.
- **Suggest new skills:** when a task or workflow repeats and would make a good skill, suggest creating one: name it and say what it would do. Don't create it without approval.
