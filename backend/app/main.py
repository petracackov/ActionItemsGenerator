"""FastAPI app: creates the app and registers routes."""

from fastapi import FastAPI

from app.config import load_settings

# Runs once at startup. Stops the server immediately if config is missing.
settings = load_settings()

app = FastAPI(title="Action Item Extractor")


@app.get("/health")
def health() -> dict[str, str]:
    """Liveness check: proves the server is up."""
    return {"status": "ok"}
