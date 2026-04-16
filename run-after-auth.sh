#!/usr/bin/env bash
# Quick auth check + run
echo "Checking gh auth..."
if ! gh api user --jq '.login' 2>/dev/null | grep -q forbiddenlink; then
  echo "⚠️  Not authenticated. Run: gh auth login"
  exit 1
fi
echo "✓ Authenticated as $(gh api user --jq '.login')"
exec ~/forbiddenlink/github-presence-improvements.sh
