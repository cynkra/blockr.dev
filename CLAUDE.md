# blockr Monorepo

This is the root directory containing all blockr ecosystem packages. Each subdirectory is its own package with its own git repo.

## Core Packages

- **blockr.core** — Core framework: blocks, boards, plugins, serialization
- **blockr.dock** — Dock board layout (dockview-based panel arrangement)
- **blockr.dplyr** — dplyr-based transform blocks (filter, mutate, select, etc.)
- **blockr.ggplot** — ggplot2-based plot blocks
- **blockr.dag** — DAG visualization of block connections
- **blockr.session** — Session management, workflow persistence (pins-based)

## Design Specs

Design documents live in `blockr.design/` with subdirectories `open/`, `done/`, and `abandoned/`. See the `/blockr-spec` skill for the writing process.

## Docs

See `docs/` for workflow guidelines and other documentation.

## Rules

- **Never attribute commits to Claude Code.** Do not add `Co-Authored-By` lines to commit messages.
