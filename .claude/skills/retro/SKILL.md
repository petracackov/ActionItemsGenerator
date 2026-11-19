---
name: retro
description: Look back at what went wrong in the conversation, find why the user wasn't satisfied, and propose a rule for AGENTS.md that prevents it. Use when the user is frustrated, says "that's not what I wanted", "why did you do that", or invokes /retro.
---

# Communication retro

Find out why the user was unhappy and suggest a rule that prevents it. **Never add the rule without the user's explicit approval.**

## Steps

1. **Find the moment.** If the arguments describe the problem, start there. Otherwise, work backwards from the most recent messages until you find the friction: the user corrected you, repeated themselves, pushed back, or rejected work. Stop as soon as you find it. Don't scan the whole conversation.
2. **Diagnose.** For each issue, state briefly:
   - **What happened:** what you did or said.
   - **What the user wanted:** what they actually expected.
   - **Root cause:** why the gap happened (misread request, assumed instead of asked, too much at once, too verbose, wrong level of explanation, ignored an existing rule, etc.).
   Be honest and specific. No apologies, no padding.
3. **Check existing rules.** Read `AGENTS.md`. If a rule already covers this and was ignored, say so. Then propose sharpening that rule instead of adding a new one.
4. **Propose a rule.** One short, imperative bullet, written in the file's style, that would have prevented the issue. Name the section it goes in (usually `## Working rules`).
5. **Ask for approval.** Show the diagnosis and the proposed rule, then ask: approve, edit, or reject. Stop and wait.
6. **On approval only:** add the rule to `AGENTS.md`, or update the existing line (same rules as `/update-agents`: no duplicates, don't touch `CLAUDE.md`). Show the final line.
7. **On edit:** apply the user's changes to the proposal and ask again.
8. **On reject:** add nothing.
