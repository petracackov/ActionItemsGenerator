#!/usr/bin/env bash
# Checks that this Mac has everything needed to run the project, sets up the
# backend, and tells you what to do for anything that's missing.
#
#   ./setup.sh
#
# Safe to run again: it never overwrites an existing backend/.env.

set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND="$ROOT/backend"
ENV_FILE="$BACKEND/.env"
XCODE_PROJECT="$ROOT/MacApp/ActionItemsGenerator/ActionItemsGenerator.xcodeproj"

MIN_MACOS=26
MIN_XCODE=27

problems=0

ok()   { printf "  \033[32m✓\033[0m %s\n" "$1"; }
fail() { printf "  \033[31m✗\033[0m %s\n" "$1"; printf "      → %s\n" "$2"; problems=$((problems + 1)); }
warn() { printf "  \033[33m!\033[0m %s\n" "$1"; [ -n "${2:-}" ] && printf "      → %s\n" "$2"; }

echo "Checking tools"

# macOS
macos_version="$(sw_vers -productVersion 2>/dev/null || echo 0)"
if [ "${macos_version%%.*}" -ge "$MIN_MACOS" ]; then
  ok "macOS $macos_version"
else
  fail "macOS $macos_version (needs $MIN_MACOS or later)" \
       "The Mac app targets macOS $MIN_MACOS. Update macOS in System Settings → General → Software Update."
fi

# Xcode (full app, not just the Command Line Tools)
if xcode_output="$(xcodebuild -version 2>/dev/null)"; then
  xcode_version="$(echo "$xcode_output" | head -1 | awk '{print $2}')"
  if [ "${xcode_version%%.*}" -ge "$MIN_XCODE" ]; then
    ok "Xcode $xcode_version"
  else
    fail "Xcode $xcode_version (needs $MIN_XCODE or later)" \
         "Install Xcode $MIN_XCODE from the App Store or developer.apple.com/download."
  fi
else
  fail "Xcode not found (or only the Command Line Tools are selected)" \
       "Install Xcode $MIN_XCODE+, then run: sudo xcode-select -s /Applications/Xcode.app"
fi

# uv (installs Python and the backend libraries)
if command -v uv >/dev/null 2>&1; then
  ok "uv $(uv --version | awk '{print $2}')"
else
  fail "uv not found" \
       "Install it: curl -LsSf https://astral.sh/uv/install.sh | sh  (then open a new terminal and run ./setup.sh again)"
fi

echo
echo "Setting up the backend"

# backend/.env with the Groq key
if [ ! -f "$ENV_FILE" ]; then
  cp "$BACKEND/.env.example" "$ENV_FILE"
  ok "Created backend/.env from .env.example"
fi

current_key="$(grep -E '^GROQ_API_KEY=' "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '[:space:]')"
if [ -z "$current_key" ] && [ -t 0 ]; then
  echo "  No Groq API key yet. Paste it here (input is hidden), or press Enter to skip:"
  read -rs current_key
  echo
  if [ -n "$current_key" ]; then
    tmp="$(mktemp)"
    grep -vE '^GROQ_API_KEY=' "$ENV_FILE" > "$tmp"
    printf 'GROQ_API_KEY=%s\n' "$current_key" | cat - "$tmp" > "$ENV_FILE"
    rm -f "$tmp"
  fi
fi

if [ -z "$current_key" ]; then
  fail "No Groq API key in backend/.env" \
       "Get a free key at https://console.groq.com/keys (or use the one sent with the submission) and put it after GROQ_API_KEY= in backend/.env."
else
  status="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 \
            -H "Authorization: Bearer $current_key" https://api.groq.com/openai/v1/models)"
  case "$status" in
    200)     ok "Groq API key works" ;;
    401|403) fail "Groq rejected the API key" \
                  "Check the key in backend/.env (no quotes or spaces), or create a new one at https://console.groq.com/keys." ;;
    *)       warn "Couldn't verify the Groq key (HTTP $status)" "Check your internet connection. The key may still be fine." ;;
  esac
fi

# Python + libraries
if command -v uv >/dev/null 2>&1; then
  if (cd "$BACKEND" && uv sync --quiet); then
    ok "Python and backend libraries installed (uv sync)"
  else
    fail "uv sync failed" "Read the error above, then run: cd backend && uv sync"
  fi
fi

# Port 8000
if lsof -nP -iTCP:8000 -sTCP:LISTEN >/dev/null 2>&1; then
  warn "Something is already running on port 8000" \
       "If it's not this backend, stop it first (lsof -nP -iTCP:8000 shows what it is)."
fi

echo
if [ "$problems" -gt 0 ]; then
  echo "Found $problems problem(s). Fix them as described above, then run ./setup.sh again."
  exit 1
fi

echo "All checks passed."
echo

SIGNING_HINT='  Signing error? Target ActionItemsGenerator → Signing & Capabilities →
  pick your own Team (automatic is fine) or "Sign to Run Locally".'

answer="n"
if [ -t 0 ]; then
  read -rp "Start the backend and open the Mac app in Xcode now? [Y/n] " answer
  echo
fi

case "$answer" in
  n|N)
    cat <<EOF
To run the project yourself:

  1. Start the backend (keep that terminal open while you use the app, Ctrl+C stops it):
       cd backend && uv run uvicorn app.main:app

  2. Open the Mac app in Xcode and press ⌘R:
       open "$XCODE_PROJECT"
$(echo "$SIGNING_HINT" | sed 's/^/   /')

More details: Documentation/Setup.md
EOF
    ;;
  *)
    open "$XCODE_PROJECT"
    echo "Opening Xcode. When it's open, press ⌘R to run the app."
    echo "$SIGNING_HINT"
    echo
    echo "Starting the backend. Keep this terminal open while you use the app. Ctrl+C stops it."
    echo
    cd "$BACKEND" && exec uv run uvicorn app.main:app
    ;;
esac
