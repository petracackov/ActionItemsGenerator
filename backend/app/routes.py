"""API routes: the thin HTTP layer. Check input, call services, shape the response."""

from datetime import UTC, datetime
from uuid import uuid4

from fastapi import APIRouter, Depends, Request

from app.errors import AppError
from app.extraction import Extractor
from app.schemas import MAX_NOTE_CHARS, ActionItemOut, ExtractRequest, NoteOut

router = APIRouter()


def get_extractor(request: Request) -> Extractor:
    """Dependency: hands the route the shared Extractor. Tests replace this with a fake."""
    return request.app.state.extractor


@router.post("/notes/extract", status_code=201, response_model=NoteOut)
def extract_note(
    body: ExtractRequest,
    request: Request,
    extractor: Extractor = Depends(get_extractor),
) -> NoteOut:
    # Plain `def` (not async): FastAPI runs it in a worker thread, so the
    # blocking Groq call doesn't stall other requests.
    text = body.text
    if not text.strip():
        raise AppError(422, "invalid_input", "The notes are empty.")
    if len(text) > MAX_NOTE_CHARS:
        raise AppError(413, "input_too_large", f"The notes are too long (max {MAX_NOTE_CHARS:,} characters).")

    result = extractor.extract(text, request.state.request_id)

    # Not saved yet (storage comes in the next branch). IDs and timestamp are created here.
    return NoteOut(
        id=uuid4(),
        text=text,
        # No microseconds: Swift's .iso8601 decoder can't parse fractional seconds.
        created_at=datetime.now(UTC).replace(microsecond=0),
        action_items=[
            ActionItemOut(id=uuid4(), done=False, **item.model_dump()) for item in result.action_items
        ],
    )
