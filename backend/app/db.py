"""Database tables and connection.

SQLModel = tables as Python classes (like SwiftData @Model). Each class with
table=True becomes a table; each field becomes a column.
"""

from collections.abc import Iterator
from datetime import datetime
from uuid import UUID, uuid4

from fastapi import Request
from sqlalchemy import event
from sqlmodel import Field, Relationship, Session, SQLModel, create_engine


class Note(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    # Who submitted the note. v1: always "local-user" (see current_user()).
    created_by: str = Field(index=True)
    text: str
    # Stored as UTC. SQLite drops the timezone, so it comes back without one.
    created_at: datetime

    action_items: list["ActionItem"] = Relationship(
        back_populates="note",
        # Keep items in the order the model returned them.
        sa_relationship_kwargs={"order_by": "ActionItem.position"},
    )


class ActionItem(SQLModel, table=True):
    __tablename__ = "action_item"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    # Foreign key: the note this item came from.
    note_id: UUID = Field(foreign_key="note.id", index=True)
    position: int
    text: str
    assignee: str | None = None
    due: str | None = None
    done: bool = False

    note: Note | None = Relationship(back_populates="action_items")


def make_engine(database_url: str):
    """The engine manages connections to the database file."""
    is_sqlite = database_url.startswith("sqlite")
    engine = create_engine(
        database_url,
        # SQLite: allow use from FastAPI's worker threads (one session per request).
        connect_args={"check_same_thread": False} if is_sqlite else {},
    )
    if is_sqlite:
        # SQLite ignores foreign keys unless asked. Turn them on for every connection.
        @event.listens_for(engine, "connect")
        def _enable_foreign_keys(connection, _record):
            connection.execute("PRAGMA foreign_keys=ON")

    return engine


def create_tables(engine) -> None:
    """Create missing tables. Existing tables and data are left as they are."""
    SQLModel.metadata.create_all(engine)


def get_session(request: Request) -> Iterator[Session]:
    """FastAPI dependency: one database session per request, closed afterwards.

    `yield` hands the session to the route; the code after it runs when the
    request is done (the `with` block closes the session)."""
    with Session(request.app.state.engine) as session:
        yield session
