# blockr Monorepo

Workspace containing all blockr ecosystem packages. See [blockr.site](https://blockr-org.github.io/blockr.site/) for documentation.

Design specs live in `_blockr.design/` (the local clone of `cynkra/blockr.design`, checked out with a leading underscore so it sorts to the top of the workspace — see `/blockr-spec` skill). Per-package dev docs are in each package's `dev/` folder.

## Handover

Cross-session / cross-container handoff goes through one file:
`_scratch/handover/HANDOVER.md` (same file at `/workspace/_scratch/handover/HANDOVER.md`
inside the devcontainer — the workspace is bind-mounted). Say **"prepare handover"**
to write the current state there, **"pick handover"** to resume from it. Procedure:
`/blockr-handoff` skill.

## Rules

- **Never attribute commits to Claude Code.** Do not add `Co-Authored-By` lines to commit messages.
- **Git in the dev container.** The default `git` command is disabled (it's a no-op stub to prevent Zed CPU drain). Use `/usr/lib/git-core/git` instead for all git operations (status, diff, add, commit, push, log, etc.). Example: `/usr/lib/git-core/git -C /workspace/blockr.core status`.
- **Shiny port.** Always serve Shiny apps on **3838** (the only port forwarded by the devcontainer). Do not use 7860 or any other port when sharing a URL with the user.
