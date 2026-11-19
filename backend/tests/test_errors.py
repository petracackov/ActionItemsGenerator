from fastapi.testclient import TestClient

from app.errors import AppError
from app.main import app


# Test-only routes that raise errors, to check the handlers.
@app.get("/_test/app-error")
def _raise_app_error():
    raise AppError(502, "llm_invalid_output", "Bad output.")


@app.get("/_test/crash")
def _raise_crash():
    raise RuntimeError("boom")


client = TestClient(app, raise_server_exceptions=False)


def assert_error_shape(response, status, code):
    assert response.status_code == status
    error = response.json()["error"]
    assert error["code"] == code
    assert error["message"]
    assert error["request_id"]


def test_app_error_uses_error_shape():
    assert_error_shape(client.get("/_test/app-error"), 502, "llm_invalid_output")


def test_unknown_route_uses_error_shape():
    assert_error_shape(client.get("/does-not-exist"), 404, "not_found")


def test_unexpected_error_returns_500_without_details():
    response = client.get("/_test/crash")
    assert_error_shape(response, 500, "internal_error")
    assert "boom" not in response.text


def test_request_id_header_is_set():
    assert client.get("/health").headers["X-Request-ID"]
