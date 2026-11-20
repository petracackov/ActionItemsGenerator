"""Shared test setup. pytest loads this file automatically before any test."""

import os
import tempfile

import pytest

# Tests never call the real Groq API, so a dummy key is enough to start the app.
os.environ.setdefault("GROQ_API_KEY", "test-key")
# Keep test logs and test data out of backend/logs and backend/data.db.
_tmp = tempfile.mkdtemp(prefix="extractor-test-")
os.environ.setdefault("LOG_DIR", _tmp)
os.environ.setdefault("DATABASE_URL", f"sqlite:///{_tmp}/test.db")


@pytest.fixture
def use_groq():
    """Call use_groq(FakeGroq(...)) in a test to plug that fake into the app."""
    from app.extraction import Extractor
    from app.main import app
    from app.routes import get_extractor

    def plug(fake):
        app.dependency_overrides[get_extractor] = lambda: Extractor(fake, "openai/gpt-oss-20b")
        return fake

    yield plug
    app.dependency_overrides.clear()
