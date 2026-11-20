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

Mac app: _TBD_
