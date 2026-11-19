# Take-Home Assignment: Action Item Extractor

> Original assignment text from the company. This is the source of truth for scope and requirements.

- **Timebox:** 4 hours. Please stop at 4 hours even if unfinished, we grade what's there, not how much of it there is.
- **Stack:** Your choice. Any language, any framework, any database.
- **AI tooling:** Encouraged. Use Claude, Copilot, Cursor, whatever you normally use. We assume you will.

## The problem

A small team takes messy notes during meetings and never turns them into action items. Build them an internal tool that does it for them.

A user pastes raw meeting notes into the app. The backend sends them to an LLM, gets back a structured list of action items, saves them, and shows them in a list the user can work with.

## What to build

- A user can submit raw meeting notes as free text
- The backend calls an LLM and gets back structured action items (not a wall of prose)
- Notes and extracted action items are persisted
- The UI shows the action items and lets the user mark them done
- A README that gets a reviewer from unzipped folder to a running app

That's the whole required scope. It is deliberately small. We are more interested in how you handle the parts that go wrong than in how many features you ship.

## Specifics

A few things we do care about the shape of, because a reviewer has to find them quickly:

- The extraction endpoint is `POST /notes/extract`
- If the model returns something unusable, discard the submission and show the user an error. We'd rather have nothing than have bad data in the system
- Extracted action items are an audit record of what the model produced. They are not editable after extraction
- Log the full note text and the model's raw response for every extraction, so we can debug what went wrong
- Extraction should complete in under two seconds

## LLM access

We do not provide an API key. Use whatever you can get for free (Google AI Studio, Groq, OpenRouter's free models, a local Ollama, anything). The specific model does not matter to us.

## Point of contact

I'm the product owner for this and am reachable during working hours.

## Sample input

There is no starter repo, set the project up however you like. Two representative notes are below. They are not exhaustive, real notes from this team look messier than these.

### Sample 1: Weekly sync, Tuesday

```
weekly sync tues

- deploy went out friday, mostly fine. two customers hit the timeout thing
  again. Ana is going to look at the retry logic, thinks it's the connection
  pool not the retries themselves
- Q3 numbers are in the shared drive, everyone please actually read them
  before next week
- new starter begins the 14th. someone needs to sort the laptop and the
  accounts, Tomaz said he'd do accounts but not the laptop
- billing page redesign -- still blocked on copy from marketing. Marko is
  chasing, said he'd have an answer by Friday
- we skipped the retro again. Let's not skip it again.
- Ana raised that the staging db hasn't been reset since June and it's
  getting slow. no owner on this yet
```

### Sample 2: Customer call, rough notes

```
call w/ Nordwind, 40 min, me + Ana

they're happy overall. two complaints:
1. export takes forever on big accounts (they have ~90k records). said
   "it's not unusable but we run it overnight now" which is not great
2. can't invite users without giving them admin. this is the third
   customer to say this.

they asked about SSO again. I said Q1 which I'm not sure is true -- need to
check with product before I put that in writing anywhere.

renewal is in March. Ana thinks we should get ahead of the export thing
before then, I agree. She's going to pull the numbers on how long exports
actually take for accounts over 50k records so we know if this is a real
problem or a perception one.

also they mentioned their new ops lead starts next month and will want a
walkthrough. no date yet.
```

## What to include in your README

This is as important as the code itself. Please cover:

1. How to run the project
2. What would you do differently with a full week
3. One decision you're not fully confident about
4. One thing you deliberately skipped, and why
