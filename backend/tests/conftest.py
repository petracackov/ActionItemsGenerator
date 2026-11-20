"""Shared test setup. pytest loads this file automatically before any test."""

import os
import tempfile

# Tests never call the real Groq API, so a dummy key is enough to start the app.
os.environ.setdefault("GROQ_API_KEY", "test-key")
# Keep test logs and test data out of backend/logs and backend/data.db.
_tmp = tempfile.mkdtemp(prefix="extractor-test-")
os.environ.setdefault("LOG_DIR", _tmp)
os.environ.setdefault("DATABASE_URL", f"sqlite:///{_tmp}/test.db")
