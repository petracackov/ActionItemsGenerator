# Setup

How to run and try the project locally.

## Prerequisites

- macOS 14+ and Xcode
- [uv](https://docs.astral.sh/uv/getting-started/installation/) (installs Python for you):
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```
- A Groq API key: create a free one at [console.groq.com/keys](https://console.groq.com/keys), or use the one sent with the submission. It goes in the backend's `.env` file, which is never committed.

## 1. Backend

```bash
cd backend
cp .env.example .env    # then put your Groq key in .env
uv sync                 # installs Python 3.12 and all libraries
uv run uvicorn app.main:app --reload
```

Check: http://127.0.0.1:8000/health returns `{"status":"ok"}`. API docs: http://127.0.0.1:8000/docs.

## 2. Mac app

_TBD_

## 3. Try it

1. Paste one of the sample notes from [Assignment.md](Assignment.md#sample-input) and click Extract.
2. Mark an item done. Restart the backend and check that it's still done.

Data is stored in `backend/data.db`. To start fresh, stop the backend and delete that file.

## 4. Tests

Backend (from `backend/`):

```bash
uv run pytest
```

Groq is faked in these tests, so they need no key and make no API calls.

### Extraction quality (optional)

Measures how well the model extracts action items, using the **real** Groq API (uses your key and free-tier quota). Run it after changing the prompt or `GROQ_MODEL`. From `backend/`:

```bash
uv run python eval/run_eval.py --runs 3
```

It sends each sample note from [Assignment.md](Assignment.md#sample-input) to the model several times and checks the result against the expected items in `backend/eval/expected.json`. It prints which items were found, a score (e.g. `30/30 (100%)`) and latency. If a run shows `ERROR llm_rate_limited`, wait a minute or use `--runs 1`.

Mac app: _TBD_
