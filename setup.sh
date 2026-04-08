#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PARENT_DIR"

# CLAUDE.md
ln -sf blockr.dev/CLAUDE.md CLAUDE.md

# Skills directory
mkdir -p .claude
rm -rf .claude/skills
ln -sfn "../blockr.dev/.claude/skills" .claude/skills

echo "Done. Symlinked CLAUDE.md and .claude/skills/."
