#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

uv --directory "$HOME/git/soggy" run generate "$HOME/Obsidian" "$SCRIPT_DIR/site" --overwrite

git -c color.status=always status -uall

echo
read -r -p "commit and push [Y/n] " reply
reply=${reply:-Y}

if [[ "$reply" =~ ^[Yy]$ ]]; then
  git add site
  git commit -m "Update site from vault"
  git push
fi
