#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git -C "$HOME/Obsidian" add -A
if ! git -C "$HOME/Obsidian" diff --cached --quiet; then
  git -C "$HOME/Obsidian" commit -m "Commit before running soggy"
fi

if [[ -n "$(git -C "$HOME/Obsidian" remote 2>/dev/null || true)" ]]; then
  git -C "$HOME/Obsidian" push
fi

uv --directory "$HOME/git/soggy" run generate "$HOME/Obsidian" "$SCRIPT_DIR/docs" --overwrite --ignore-output CNAME

git -c color.status=always status -uall

server_pid=""
cleanup() {
  if [[ -n "${server_pid:-}" ]] && kill -0 "$server_pid" 2>/dev/null; then
    kill "$server_pid"
    wait "$server_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT TERM

python3 -m http.server --directory "$SCRIPT_DIR/docs" &
server_pid=$!

echo
read -r -p "commit and push [Y/n] " reply
reply=${reply:-Y}

if [[ "$reply" =~ ^[Yy]$ ]]; then
  git add docs
  git commit -m "Update site from vault"
  git push
fi
