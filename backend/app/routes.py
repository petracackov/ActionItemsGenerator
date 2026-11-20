"""API routes: the thin HTTP layer. Check input, call services, shape the response."""

from datetime import UTC

from fastapi import APIRouter, Depends, Request
from sqlmodel import Session

from app.auth import current_user
from app.db import Note, get_session
from app.errors import AppError
from app.extraction import Extractor
from app.repository import NoteRepository
from app.schemas import MAX_NOTE_CHARS, ActionItemOut, ExtractRequest, NoteOut, NotesOut

router = APIRouter()


def get_extractor(request: Request) -> Extractor:
    """Dependency: hands the route the shared Extractor. Tests replace this with a fake."""
    return request.app.state.extractor


def to_note_out(note: Note) -> NoteOut:
    """Database row -> API response shape."""
    created_at = note.created_at
    if created_at.tzinfo is None:
        # SQLite drops the timezone. We always store UTC, so put it back.
        created_at = created_at.replace(tzinfo=UTC)
    return NoteOut(
        id=note.id,
        text=note.text,
        created_at=created_at,
        action_items=[
            ActionItemOut(id=item.id, text=item.text, assignee=item.assignee, due=item.due, done=item.done)
            for item in note.action_items
        ],
    )


@router.post("/notes/extract", status_code=201, response_model=NoteOut)
def extract_note(
    body: ExtractRequest,
    request: Request,
    extractor: Extractor = Depends(get_extractor),
    session: Session = Depends(get_session),
    user: str = Depends(current_user),
) -> NoteOut:
    # Plain `def` (not async): FastAPI runs it in a worker thread, so the
    # blocking Groq call doesn't stall other requests.
    text = body.text
    if not text.strip():
        raise AppError(422, "invalid_input", "The notes are empty.")
    if len(text) > MAX_NOTE_CHARS:
        raise AppError(413, "input_too_large", f"The notes are too long (max {MAX_NOTE_CHARS:,} characters).")

    # Raises AppError on any extraction failure, so we only reach the save with valid items.
    result = extractor.extract(text, request.state.request_id)

    note = NoteRepository(session).create(created_by=user, text=text, items=result.action_items)
    return to_note_out(note)


@router.get("/notes", response_model=NotesOut)
def list_notes(
    session: Session = Depends(get_session),
    user: str = Depends(current_user),
) -> NotesOut:
    notes = NoteRepository(session).list_for(user)
    return NotesOut(notes=[to_note_out(note) for note in notes])
