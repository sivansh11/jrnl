#!/usr/bin/env bash
set -euo pipefail

JRNL_URL="https://raw.githubusercontent.com/sivansh11/jrnl/main/jrnl"
APP_DIR="$HOME/.local/share/jrnl"
BIN_DIR="$HOME/.local/bin"
VENV_DIR="$APP_DIR/venv"
WRAPPER="$BIN_DIR/jrnl"

USAGE="usage: install.sh [--uninstall] [--help]

Installs the jrnl CLI to ~/.local (no sudo required).
Re-running installs updates jrnl to the latest version.

  --uninstall  remove jrnl and its venv (journal data in ~/.jrnl is kept)
  --help       show this help"

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' "$USAGE"
    exit 0
fi

if [ "${1:-}" = "--uninstall" ]; then
    rm -f "$WRAPPER"
    rm -rf "$APP_DIR"
    echo "jrnl uninstalled. (journal data in ~/.jrnl was left untouched)"
    exit 0
fi

[ -n "${1:-}" ] && { echo "error: unknown argument: $1" >&2; printf '%s\n' "$USAGE" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || { echo "error: curl not found" >&2; exit 1; }

PYTHON=""
for p in python3 python3.12 python3.11 python3.10; do
    command -v "$p" >/dev/null 2>&1 && PYTHON="$p" && break
done
[ -n "$PYTHON" ] || { echo "error: no python3 (>=3.10) found" >&2; exit 1; }

mkdir -p "$BIN_DIR" "$APP_DIR"
echo "downloading jrnl..."
curl -fsSL "$JRNL_URL" -o "$APP_DIR/jrnl"
[ -s "$APP_DIR/jrnl" ] || { echo "error: failed to download jrnl" >&2; exit 1; }
chmod +x "$APP_DIR/jrnl"

if [ ! -d "$VENV_DIR" ]; then
    echo "creating virtualenv..."
    "$PYTHON" -m venv "$VENV_DIR"
fi
echo "installing openai dependency..."
"$VENV_DIR/bin/pip" install --quiet --upgrade "openai>=1.0"

cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
exec "$VENV_DIR/bin/python" "$APP_DIR/jrnl" "\$@"
EOF
chmod +x "$WRAPPER"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "note: add $BIN_DIR to your PATH:"
       echo "  export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

echo "jrnl installed. Run: jrnl --help"
