# Shared Config — Design

## Current approach: master repo

Nicolas's blockr.dev is the parent folder. Sub-packages are cloned inside and gitignored. Tool-specific files (`CLAUDE.md`, `.claude/skills/`) live directly in blockr.dev.

**Problem 1:** Nested git repos confuse editors. Zed can't show per-repo change status when the parent is also a git repo.

**Problem 2:** Tool-specific paths are baked into the repo. blockr.dev is tied to Claude Code.

## Proposed: symlinks from a tool-agnostic repo

blockr.dev stores config under generic names (`AGENTS.md`, `skills/`). A setup script symlinks them to tool-specific locations in the parent directory. The script takes a tool parameter — `setup.sh claude` creates `CLAUDE.md` and `.claude/skills/`; a future `setup.sh cursor` would create whatever Cursor expects.

```
~/git/blockr/              # plain folder, NOT a git repo
  CLAUDE.md                # → blockr.dev/AGENTS.md  (created by setup.sh)
  .claude/skills/          # → blockr.dev/skills/    (created by setup.sh)
  blockr.core/             # independent git repo
  blockr.dev/              # independent git repo
    AGENTS.md              # tool-agnostic
    skills/                # tool-agnostic
    docs/                  # detailed documentation
  blockr.dplyr/            # independent git repo
```

Editors see independent repos with proper change tracking. Updates propagate via `git pull` in blockr.dev. Adding a second tool means adding a mapping to the setup script — blockr.dev doesn't change.

**Limitation:** No private project-scoped config — the project level is fully shared. Private settings go in the tool's user-level config (e.g., `~/.claude/`).

## Role of AGENTS.md

AGENTS.md is loaded into every session as part of the system prompt. Many sessions are writing specs or doing research, not coding. Keep it minimal:

- Ecosystem overview (one paragraph)
- Pointers to `docs/` (e.g., "see `docs/workflow.md`")

Everything else — workflow, code style, documentation conventions, testing — lives in `docs/` and gets pulled in on demand. Nicolas's current AGENTS.md (~210 lines) is all coding-specific content. All of it moves to `docs/`. AGENTS.md shrinks to ~10 lines.
