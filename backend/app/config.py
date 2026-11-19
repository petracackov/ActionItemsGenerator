"""App settings, read from environment variables (and backend/.env if present)."""

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

BACKEND_DIR = Path(__file__).resolve().parent.parent

# Copies values from backend/.env into environment variables.
# Real environment variables win over .env.
load_dotenv(BACKEND_DIR / ".env")


DEFAULT_GROQ_MODEL = "openai/gpt-oss-20b"


@dataclass(frozen=True)
class Settings:
    groq_api_key: str
    groq_model: str


def load_settings() -> Settings:
    """Return settings, or stop the server with a clear message if something is missing."""
    key = os.getenv("GROQ_API_KEY", "").strip()
    if not key:
        raise SystemExit(
            "GROQ_API_KEY is missing. "
            "Copy backend/.env.example to backend/.env and add your Groq key."
        )
    model = os.getenv("GROQ_MODEL", "").strip() or DEFAULT_GROQ_MODEL
    return Settings(groq_api_key=key, groq_model=model)
