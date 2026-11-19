"""Extraction log: one JSON line per extraction attempt in logs/extractions.log.

Each line has the full note, the model's raw response and the outcome, so any
failure can be debugged later by its request_id. See Documentation/ErrorHandling.md.
"""

import json
import logging
from datetime import UTC, datetime
from pathlib import Path

SLOW_EXTRACTION_MS = 2000

_log = logging.getLogger("app.extraction")


def setup_logging(log_dir: Path) -> None:
    """Send extraction records to a file (one JSON object per line) and slow/failed ones also to the console."""
    if _log.handlers:  # already set up
        return
    log_dir.mkdir(parents=True, exist_ok=True)

    file_handler = logging.FileHandler(log_dir / "extractions.log", encoding="utf-8")
    file_handler.setFormatter(logging.Formatter("%(message)s"))
    _log.addHandler(file_handler)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.WARNING)
    console_handler.setFormatter(logging.Formatter("%(levelname)s %(message)s"))
    _log.addHandler(console_handler)

    _log.setLevel(logging.INFO)
    _log.propagate = False


def log_extraction(
    *,
    request_id: str,
    model: str,
    note: str,
    raw_response: str | None,
    outcome: str,
    duration_ms: int,
) -> None:
    """outcome is "ok" or an error code like "llm_invalid_output"."""
    record = {
        "ts": datetime.now(UTC).isoformat(timespec="seconds"),
        "request_id": request_id,
        "model": model,
        "outcome": outcome,
        "duration_ms": duration_ms,
        "slow": duration_ms > SLOW_EXTRACTION_MS,
        "note": note,
        "raw_response": raw_response,
    }
    is_problem = outcome != "ok" or record["slow"]
    _log.log(logging.WARNING if is_problem else logging.INFO, json.dumps(record, ensure_ascii=False))
