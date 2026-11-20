"""Shared test helpers: a fake Groq client and a valid model reply."""

import json
from types import SimpleNamespace

import httpx

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
