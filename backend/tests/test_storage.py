"""Saving on extract, GET /notes and PATCH /items/{id}, against a temporary database."""

from datetime import UTC, datetime, timedelta

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import Session, delete, func, select

from app.db import ActionItem, Note
from app.main import app
from tests.fakes import FakeGroq

client = TestClient(app)
engine = app.state.engine


@pytest.fixture(autouse=True)
def empty_db(use_groq):
    """autouse: runs before every test in this file. Starts each test with empty tables
    and a fake Groq that returns two valid items."""
    with Session(engine) as session:
        session.exec(delete(ActionItem))
        session.exec(delete(Note))
        session.commit()
    use_groq(FakeGroq())


def extract(text="weekly sync notes"):
    response = client.post("/notes/extract", json={"text": text})
    assert response.status_code == 201
    return response.json()


def list_notes():
    response = client.get("/notes")
    assert response.status_code == 200
    return response.json()["notes"]


def note_count() -> int:
    with Session(engine) as session:
        return session.exec(select(func.count()).select_from(Note)).one()


def patch(item_id, body):
    return client.patch(f"/items/{item_id}", json=body)


# --- Saving on extract ---------------------------------------------------------------


def test_extract_saves_note_and_items():
    created = extract()

    notes = list_notes()
    assert len(notes) == 1
    assert notes[0] == created  # same IDs, text, items and order as the POST response


def test_failed_extraction_saves_nothing(use_groq):
    use_groq(FakeGroq(reply="not json"))

    assert client.post("/notes/extract", json={"text": "notes"}).status_code == 502
    assert note_count() == 0


def test_failed_save_rolls_back_and_returns_500(monkeypatch):
    def failing_commit(self):
        raise SQLAlchemyError("disk full")

    monkeypatch.setattr(Session, "commit", failing_commit)
    response = client.post("/notes/extract", json={"text": "notes"})
    monkeypatch.undo()

    assert response.status_code == 500
    assert response.json()["error"]["code"] == "storage_error"
    assert note_count() == 0


# --- GET /notes ----------------------------------------------------------------------


def test_list_is_empty_at_start():
    assert list_notes() == []


def test_list_is_newest_first():
    with Session(engine) as session:
        now = datetime.now(UTC).replace(microsecond=0)
        session.add(Note(created_by="local-user", text="older", created_at=now - timedelta(minutes=5)))
        session.add(Note(created_by="local-user", text="newer", created_at=now))
        session.commit()

    assert [n["text"] for n in list_notes()] == ["newer", "older"]


def test_list_dates_are_utc_without_microseconds():
    extract()
    created_at = list_notes()[0]["created_at"]
    assert created_at.endswith("Z") and "." not in created_at


def test_list_hides_other_users_notes():
    with Session(engine) as session:
        session.add(Note(created_by="someone-else", text="private", created_at=datetime.now(UTC)))
        session.commit()

    assert list_notes() == []


# --- PATCH /items/{id} ---------------------------------------------------------------


def first_item_id() -> str:
    return extract()["action_items"][0]["id"]


def test_mark_done_and_undone_is_saved():
    item_id = first_item_id()

    response = patch(item_id, {"done": True})
    assert response.status_code == 200
    assert response.json()["done"] is True
    assert list_notes()[0]["action_items"][0]["done"] is True

    assert patch(item_id, {"done": False}).json()["done"] is False
    assert list_notes()[0]["action_items"][0]["done"] is False


@pytest.mark.parametrize(
    "body",
    [
        {"done": True, "text": "changed"},  # items are immutable
        {"done": "yes"},  # only true/false
        {"done": 1},
        {},
    ],
)
def test_invalid_patch_body_is_rejected_and_nothing_changes(body):
    item_id = first_item_id()

    response = patch(item_id, body)

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "invalid_input"
    item = list_notes()[0]["action_items"][0]
    assert item["done"] is False
    assert item["text"] == "Look at the retry logic"


def test_unknown_item_is_404():
    response = patch("00000000-0000-0000-0000-000000000000", {"done": True})
    assert response.status_code == 404
    assert response.json()["error"]["code"] == "not_found"


def test_invalid_item_id_is_422():
    assert patch("not-a-uuid", {"done": True}).status_code == 422


def test_other_users_item_is_404():
    with Session(engine) as session:
        note = Note(created_by="someone-else", text="private", created_at=datetime.now(UTC))
        note.action_items = [ActionItem(position=0, text="their task")]
        session.add(note)
        session.commit()
        their_item_id = note.action_items[0].id

    assert patch(their_item_id, {"done": True}).status_code == 404
