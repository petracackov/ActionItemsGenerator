"""Who is making the request. The only place auth lives.

v1: no login, every request belongs to one fixed user.
v2: read the Supabase token from the Authorization header, verify it,
return the real user ID (or raise 401). No other code needs to change.
See Documentation/Architecture.md (v2) and Documentation/Decisions.md (section 5).
"""

LOCAL_USER = "local-user"


def current_user() -> str:
    """FastAPI dependency: routes get the user ID via Depends(current_user)."""
    return LOCAL_USER
