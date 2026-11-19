"""Data shapes (Pydantic models) for the LLM output and the API.

Pydantic models are like Codable structs with validation rules: parsing data
into them either succeeds or raises a ValidationError.
"""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

MAX_NOTE_CHARS = 10_000
MAX_ITEMS = 50
MAX_ITEM_TEXT_CHARS = 500


# --- What the LLM must return (internal) -------------------------------------


class LLMActionItem(BaseModel):
    # forbid: unknown fields are an error. strip: "  " becomes "" and fails min_length.
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    text: str = Field(min_length=1, max_length=MAX_ITEM_TEXT_CHARS)
    assignee: str | None
    due: str | None

    @field_validator("assignee", "due")
    @classmethod
    def empty_to_none(cls, value: str | None) -> str | None:
        """Treat "" as "not mentioned"."""
        return value or None


class LLMOutput(BaseModel):
    model_config = ConfigDict(extra="forbid")

    action_items: list[LLMActionItem] = Field(max_length=MAX_ITEMS)


# JSON Schema sent to Groq for strict Structured Outputs. Hand-written because strict
# mode needs every field in "required" and additionalProperties: false.
# Must match LLMOutput above (checked by a test). Length limits are enforced by
# LLMOutput, not here.
LLM_JSON_SCHEMA: dict = {
    "type": "object",
    "properties": {
        "action_items": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "text": {"type": "string"},
                    "assignee": {"type": ["string", "null"]},
                    "due": {"type": ["string", "null"]},
                },
                "required": ["text", "assignee", "due"],
                "additionalProperties": False,
            },
        }
    },
    "required": ["action_items"],
    "additionalProperties": False,
}


# --- API request / response ----------------------------------------------------


class ExtractRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    # Length rules are checked in the route, so it can return 422 vs 413.
    text: str


class ActionItemOut(BaseModel):
    id: UUID
    text: str
    assignee: str | None
    due: str | None
    done: bool


class NoteOut(BaseModel):
    id: UUID
    text: str
    created_at: datetime
    action_items: list[ActionItemOut]
