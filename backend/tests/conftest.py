"""Shared test setup. pytest loads this file automatically before any test."""

import os
import tempfile

# Tests never call the real Groq API, so a dummy key is enough to start the app.
os.environ.setdefault("GROQ_API_KEY", "test-key")
# Keep test log lines out of backend/logs.
os.environ.setdefault("LOG_DIR", tempfile.mkdtemp(prefix="extractor-test-logs-"))
