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

uv --directory "$HOME/git/soggy" run generate "$HOME/Obsidian" "$SCRIPT_DIR/docs" --overwrite

git -c color.status=always status -uall

echo
read -r -p "commit and push [Y/n] " reply
reply=${reply:-Y}

if [[ "$reply" =~ ^[Yy]$ ]]; then
  git add docs
  git commit -m "Update site from vault"
  git push
fi
