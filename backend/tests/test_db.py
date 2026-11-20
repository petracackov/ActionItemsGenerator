from datetime import UTC, datetime

import pytest
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.db import ActionItem, Note, create_tables, make_engine


@pytest.fixture
def engine(tmp_path):
    engine = make_engine(f"sqlite:///{tmp_path}/db.sqlite")
    create_tables(engine)
    return engine


def test_note_with_items_round_trips_in_order(engine):
    note = Note(created_by="local-user", text="notes", created_at=datetime.now(UTC))
    note.action_items = [
        ActionItem(position=1, text="second"),
        ActionItem(position=0, text="first", assignee="Ana"),
    ]
    with Session(engine) as session:
        session.add(note)
        session.commit()
        note_id = note.id

    with Session(engine) as session:
        loaded = session.get(Note, note_id)
        assert [i.text for i in loaded.action_items] == ["first", "second"]
        assert loaded.action_items[0].assignee == "Ana"
        assert loaded.action_items[0].done is False


def test_item_must_belong_to_existing_note(engine):
    # Foreign keys are enforced: an item pointing at no note is rejected.
    from uuid import uuid4

    with Session(engine) as session:
        session.add(ActionItem(note_id=uuid4(), position=0, text="orphan"))
        with pytest.raises(IntegrityError):
            session.commit()
