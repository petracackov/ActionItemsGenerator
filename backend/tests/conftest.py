"""Shared test setup. pytest loads this file automatically before any test."""

import os

# Tests never call the real Groq API, so a dummy key is enough to start the app.
os.environ.setdefault("GROQ_API_KEY", "test-key")
