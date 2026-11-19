"""POST /notes/extract end to end, with Groq replaced by a fake client.

The real Extractor runs (prompt, error mapping, validation, logging); only the
network call to Groq is faked, so every failure case can be triggered on demand.
"""

import json
import os
from pathlib import Path
from types import SimpleNamespace

import groq
import httpx
import pytest
from fastapi.testclient import TestClient

from app.extraction import Extractor
from app.main import app
from app.routes import get_extractor

GROQ_REQUEST = httpx.Request("POST", "https://api.groq.com/openai/v1/chat/completions")
VALID_REPLY = json.dumps(
    {
        "action_items": [
            {"text": "Look at the retry logic", "assignee": "Ana", "due": None},
            {"text": "Chase marketing for copy", "assignee": "Marko", "due": "Friday"},
        ]
    }
)


class FakeGroq:
    """Stands in for groq.Groq. Returns `reply` or raises `error`."""

    def __init__(self, reply: str | None = VALID_REPLY, error: Exception | None = None):
        self.reply, self.error = reply, error
        self.calls: list[dict] = []
        self.chat = SimpleNamespace(completions=SimpleNamespace(create=self._create))

    def _create(self, **kwargs):
        self.calls.append(kwargs)
        if self.error:
            raise self.error
        return SimpleNamespace(choices=[SimpleNamespace(message=SimpleNamespace(content=self.reply))])


@pytest.fixture
def use_groq():
    """Call use_groq(FakeGroq(...)) in a test to plug that fake into the app."""

    def plug(fake: FakeGroq) -> FakeGroq:
        app.dependency_overrides[get_extractor] = lambda: Extractor(fake, "openai/gpt-oss-20b")
        return fake

    yield plug
    app.dependency_overrides.clear()


client = TestClient(app)


def post(text="weekly sync notes"):
    return client.post("/notes/extract", json={"text": text})


def assert_error(response, status, code):
    assert response.status_code == status
    error = response.json()["error"]
    assert error["code"] == code
    assert error["request_id"] == response.headers["X-Request-ID"]


# --- Happy path -------------------------------------------------------------------


def test_valid_reply_returns_201_note(use_groq):
    fake = use_groq(FakeGroq())

    response = post()

    assert response.status_code == 201
    note = response.json()
    assert note["text"] == "weekly sync notes"
    assert note["created_at"].endswith("Z") and "." not in note["created_at"]  # no microseconds
    items = note["action_items"]
    assert [i["assignee"] for i in items] == ["Ana", "Marko"]
    assert all(i["done"] is False and i["id"] for i in items)
    # Strict Structured Outputs was requested.
    assert fake.calls[0]["response_format"]["json_schema"]["strict"] is True


def test_no_action_items_is_still_201(use_groq):
    use_groq(FakeGroq(reply='{"action_items": []}'))
    response = post()
    assert response.status_code == 201
    assert response.json()["action_items"] == []


# --- Input errors (Groq is never called) --------------------------------------------


@pytest.mark.parametrize("text", ["", "   \n\t "])
def test_empty_notes_rejected(use_groq, text):
    fake = use_groq(FakeGroq())
    assert_error(post(text), 422, "invalid_input")
    assert fake.calls == []


def test_too_long_notes_rejected(use_groq):
    fake = use_groq(FakeGroq())
    assert_error(post("x" * 10_001), 413, "input_too_large")
    assert fake.calls == []


@pytest.mark.parametrize("body", [{}, {"text": 123}, {"text": "hi", "extra": 1}])
def test_malformed_body_rejected(use_groq, body):
    use_groq(FakeGroq())
    assert_error(client.post("/notes/extract", json=body), 422, "invalid_input")


# --- Groq call failures ------------------------------------------------------------


@pytest.mark.parametrize(
    "error, status, code",
    [
        (groq.APITimeoutError(request=GROQ_REQUEST), 504, "llm_timeout"),
        (
            groq.RateLimitError("rate limited", response=httpx.Response(429, request=GROQ_REQUEST), body=None),
            503,
            "llm_rate_limited",
        ),
        (groq.APIConnectionError(request=GROQ_REQUEST), 502, "llm_unavailable"),
        (
            groq.AuthenticationError("bad key", response=httpx.Response(401, request=GROQ_REQUEST), body=None),
            502,
            "llm_unavailable",
        ),
    ],
)
def test_groq_failures_map_to_error_codes(use_groq, error, status, code):
    use_groq(FakeGroq(error=error))
    assert_error(post(), status, code)


# --- Unusable model output ---------------------------------------------------------


@pytest.mark.parametrize(
    "reply",
    [
        "not json at all",
        "",
        '{"items": []}',  # wrong root key
        '{"action_items": [{"text": "ok", "assignee": null}]}',  # missing field
        # One valid item, one invalid: the whole submission is discarded.
        '{"action_items": [{"text": "ok", "assignee": null, "due": null}, {"text": "", "assignee": null, "due": null}]}',
    ],
)
def test_unusable_output_returns_502(use_groq, reply):
    use_groq(FakeGroq(reply=reply))
    assert_error(post(), 502, "llm_invalid_output")


# --- Logging -----------------------------------------------------------------------


def last_log_entry() -> dict:
    log_file = Path(os.environ["LOG_DIR"]) / "extractions.log"
    return json.loads(log_file.read_text().strip().splitlines()[-1])


def test_success_is_logged_with_note_and_raw_reply(use_groq):
    use_groq(FakeGroq())
    response = post("notes to log")

    entry = last_log_entry()
    assert entry["request_id"] == response.headers["X-Request-ID"]
    assert entry["outcome"] == "ok"
    assert entry["note"] == "notes to log"
    assert entry["raw_response"] == VALID_REPLY


def test_failure_is_logged_with_raw_reply(use_groq):
    use_groq(FakeGroq(reply="garbage"))
    response = post("bad run")

    entry = last_log_entry()
    assert entry["request_id"] == response.headers["X-Request-ID"]
    assert entry["outcome"] == "llm_invalid_output"
    assert entry["note"] == "bad run"
    assert entry["raw_response"] == "garbage"
