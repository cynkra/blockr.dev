# blockr Monorepo

Workspace containing all blockr ecosystem packages. See [blockr.site](https://blockr-org.github.io/blockr.site/) for documentation.

Design specs live in `blockr.design/` (see `/blockr-spec` skill). Per-package dev docs are in each package's `dev/` folder.

## Rules

- **Never attribute commits to Claude Code.** Do not add `Co-Authored-By` lines to commit messages.
- **Git in the dev container.** The default `git` command is disabled (it's a no-op stub to prevent Zed CPU drain). Use `/usr/lib/git-core/git` instead for all git operations (status, diff, add, commit, push, log, etc.). Example: `/usr/lib/git-core/git -C /workspace/blockr.core status`.
- **Shiny port.** Always serve Shiny apps on **3838** (the only port forwarded by the devcontainer). Do not use 7860 or any other port when sharing a URL with the user.
