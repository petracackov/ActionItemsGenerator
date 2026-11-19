"""One error type and the handlers that turn every error into the same JSON shape:

    { "error": { "code": "...", "message": "...", "request_id": "..." } }

See Documentation/ErrorHandling.md.
"""

import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger("app")


class AppError(Exception):
    """Raise this anywhere to return a specific error to the client."""

    def __init__(self, status_code: int, code: str, message: str):
        super().__init__(message)
        self.status_code = status_code
        self.code = code
        self.message = message


def _error_response(request: Request, status_code: int, code: str, message: str) -> JSONResponse:
    request_id = getattr(request.state, "request_id", None)
    return JSONResponse(
        status_code=status_code,
        content={"error": {"code": code, "message": message, "request_id": request_id}},
    )


def register_error_handlers(app: FastAPI) -> None:
    """Exception handlers: FastAPI calls these instead of crashing when an error is raised."""

    @app.exception_handler(AppError)
    async def handle_app_error(request: Request, exc: AppError) -> JSONResponse:
        return _error_response(request, exc.status_code, exc.code, exc.message)

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(request: Request, exc: RequestValidationError) -> JSONResponse:
        # Body missing, not JSON, wrong types, unknown fields.
        return _error_response(request, 422, "invalid_input", "The request body is invalid.")

    @app.exception_handler(StarletteHTTPException)
    async def handle_http_error(request: Request, exc: StarletteHTTPException) -> JSONResponse:
        # E.g. unknown URL (404) or wrong method (405).
        code = "not_found" if exc.status_code == 404 else "http_error"
        return _error_response(request, exc.status_code, code, str(exc.detail))

    @app.exception_handler(Exception)
    async def handle_unexpected_error(request: Request, exc: Exception) -> JSONResponse:
        # A bug on our side. Log the full traceback, return a generic message.
        log.exception("Unexpected error (request_id=%s)", getattr(request.state, "request_id", None))
        return _error_response(request, 500, "internal_error", "Something went wrong on the server.")
