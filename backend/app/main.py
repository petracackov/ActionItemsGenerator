"""FastAPI app: creates the app and registers routes."""

import uuid

from fastapi import FastAPI, Request

from app.config import load_settings
from app.errors import register_error_handlers
from app.extraction import Extractor, make_groq_client
from app.logger import setup_logging
from app.routes import router

# Runs once at startup. Stops the server immediately if config is missing.
settings = load_settings()
setup_logging(settings.log_dir)

app = FastAPI(title="Action Item Extractor")
register_error_handlers(app)
app.include_router(router)

# One shared Extractor for all requests, read by routes via get_extractor().
app.state.extractor = Extractor(make_groq_client(settings.groq_api_key), settings.groq_model)


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
