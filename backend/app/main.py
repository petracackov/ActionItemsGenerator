"""FastAPI app: creates the app and registers routes."""

import uuid

from fastapi import FastAPI, Request

from app.config import load_settings
from app.errors import register_error_handlers

# Runs once at startup. Stops the server immediately if config is missing.
settings = load_settings()

app = FastAPI(title="Action Item Extractor")
register_error_handlers(app)


@app.middleware("http")
async def add_request_id(request: Request, call_next):
    """Middleware runs around every request. Gives each one a short ID used in
    error responses and logs, and returns it in the X-Request-ID header."""
    request.state.request_id = uuid.uuid4().hex[:12]
    response = await call_next(request)
    response.headers["X-Request-ID"] = request.state.request_id
    return response


@app.get("/health")
def health() -> dict[str, str]:
    """Liveness check: proves the server is up."""
    return {"status": "ok"}
