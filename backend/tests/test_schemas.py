import pytest
from pydantic import ValidationError

from app.schemas import LLM_JSON_SCHEMA, MAX_ITEMS, LLMActionItem, LLMOutput


def item(**overrides):
    return {"text": "Do the thing", "assignee": "Ana", "due": None, **overrides}


def test_valid_output_parses():
    out = LLMOutput.model_validate({"action_items": [item()]})
    assert out.action_items[0].assignee == "Ana"


def test_empty_list_is_valid():
    assert LLMOutput.model_validate({"action_items": []}).action_items == []


@pytest.mark.parametrize(
    "bad",
    [
        {"action_items": [item(text="")]},  # empty text
        {"action_items": [item(text="   ")]},  # whitespace only
        {"action_items": [item(text="x" * 501)]},  # too long
        {"action_items": [item(extra="nope")]},  # unknown field
        {"action_items": [{"text": "Missing fields"}]},  # missing assignee/due
        {"action_items": [item()] * (MAX_ITEMS + 1)},  # too many items
        {"items": []},  # wrong root key
    ],
)
def test_unusable_output_is_rejected(bad):
    with pytest.raises(ValidationError):
        LLMOutput.model_validate(bad)


def test_empty_strings_become_none():
    parsed = LLMActionItem.model_validate(item(assignee="", due=""))
    assert parsed.assignee is None and parsed.due is None


def test_json_schema_matches_model_fields():
    schema_fields = set(LLM_JSON_SCHEMA["properties"]["action_items"]["items"]["properties"])
    assert schema_fields == set(LLMActionItem.model_fields)
