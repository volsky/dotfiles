#!/bin/bash
set -e

cd "$(dirname "$0")"

if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "Already up to date"
  exit 0
fi

git add .
git commit -m "sync $(date +%Y-%m-%d)"
git push
