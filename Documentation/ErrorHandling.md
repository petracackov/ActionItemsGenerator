# Error handling

Everything that can go wrong, and what happens. Overview: [Architecture.md](Architecture.md). Reasoning behind the defaults: [Decisions.md → 7](Decisions.md#7-error-handling-defaults).

**Core rule:** if anything in an extraction fails, **nothing is saved** and the user gets a clear error. Better nothing than bad data.

Status codes: `4xx` means the client sent something wrong, and `5xx` means the server or something it depends on (Groq, the DB) failed.

---

## Error format

Every error response has the same JSON shape, so the app decodes one type:

```json
{
  "error": {
    "code": "llm_invalid_output",
    "message": "The model returned unusable output. Nothing was saved.",
    "request_id": "a1b2c3"
  }
}
```

- `code`: stable, machine-readable. The app can switch on it.
- `message`: human-readable. The app shows it as is.
- `request_id`: matches the log entry (note text and raw LLM response) for debugging.

---

## 1. Input

| Case | Handling | Status | `code` |
|---|---|---|---|
| Empty or whitespace-only notes | Rejected before calling the LLM | `422` | `invalid_input` |
| Notes over 10,000 characters | Rejected before calling the LLM | `413` | `input_too_large` |
| No action items in the notes | Valid. Note saved with an empty item list, and the app shows "No action items found" | `201` | — |

## 2. Calling Groq

| Case | Handling | Status | `code` |
|---|---|---|---|
| No response within 5s | Aborted, nothing saved | `504` | `llm_timeout` |
| Rate limit (free tier) | Nothing saved, "try again shortly" | `503` | `llm_rate_limited` |
| Groq down or network error | Nothing saved | `502` | `llm_unavailable` |
| Missing API key | **Server doesn't start**, and the error is printed at startup | — | — |

## 3. Groq's response

| Case | Handling | Status | `code` |
|---|---|---|---|
| Not valid JSON | Whole submission discarded | `502` | `llm_invalid_output` |
| Wrong shape (missing fields, wrong types) | Whole submission discarded | `502` | `llm_invalid_output` |
| Some items valid, some not | **Whole** submission discarded (all or nothing) | `502` | `llm_invalid_output` |
| Empty item text, or more than 50 items | Treated as unusable | `502` | `llm_invalid_output` |
| Prompt injection in the notes | Limited by schema validation: only well-formed items pass | — | — |

No automatic retry. The user can submit again.

## 4. Saving

| Case | Handling | Status | `code` |
|---|---|---|---|
| DB write fails | Transaction rolled back, nothing partial saved | `500` | `storage_error` |

## 5. Mark done (`PATCH /items/{id}`)

| Case | Handling | Status | `code` |
|---|---|---|---|
| Item doesn't exist (v2: or isn't yours) | Not found | `404` | `not_found` |
| Body tries to change anything other than `done` | Rejected. Items are immutable | `422` | `invalid_input` |

## 6. Mac app

| Case | Handling |
|---|---|
| Backend not running | "Can't reach the server at localhost:8000." |
| Request in flight | Extract button disabled (no double submits) |
| Any error response | Show `message`, keep the notes in the text field so nothing is lost |

---

## Logging

Every extraction attempt (success or failure) logs:
- `request_id`
- full note text
- raw LLM response (if any)
- outcome (`ok` or the error `code`)
- duration in ms. Anything over 2s is logged as a warning.
