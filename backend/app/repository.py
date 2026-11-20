"""Repository: the only code that reads or writes the database.

Every query filters by `created_by`, so in v2 users only ever see their own notes.
"""

from datetime import UTC, datetime

from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import Session

from app.db import ActionItem, Note
from app.errors import AppError
from app.schemas import LLMActionItem


class NoteRepository:
    def __init__(self, session: Session):
        self.session = session

    def create(self, *, created_by: str, text: str, items: list[LLMActionItem]) -> Note:
        """Save a note and its items in one transaction: all of it, or nothing."""
        note = Note(
            created_by=created_by,
            text=text,
            # No microseconds: Swift's .iso8601 decoder can't parse fractional seconds.
            created_at=datetime.now(UTC).replace(microsecond=0),
            action_items=[
                ActionItem(position=index, **item.model_dump()) for index, item in enumerate(items)
            ],
        )
        self.session.add(note)
        self._commit()
        self.session.refresh(note)
        return note

    def _commit(self) -> None:
        try:
            self.session.commit()
        except SQLAlchemyError:
            # Undo everything from this transaction, so nothing partial is saved.
            self.session.rollback()
            raise AppError(500, "storage_error", "Could not save to the database. Nothing was saved.")
