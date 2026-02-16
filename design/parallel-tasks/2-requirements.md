# Parallel Tasks — Requirements

## Source isolation

Each task gets its own working copy of the sub-packages it modifies, via git worktrees. Changes in one task don't appear in another. Packages not touched by a task are accessible from the main workspace (read-only from the task's perspective).

Packages are added to a task incrementally — not all specified upfront. A task can touch one package or several, no fixed limit.

## Library isolation

Each task gets its own R package library. Installing a package in one task doesn't affect any other task or the baseline.

Implementation: symlink-based. At task creation, every package in the baseline library (`.devcontainer/.library/`) is symlinked into the task library. When a task installs a modified package (e.g. `R CMD INSTALL` from a worktree), the symlink is replaced with the real installed package. Only packages that differ from baseline take up disk space.

## Cheap task creation

Creating a task takes seconds. No copying of the baseline library. No full repo clones. Just a directory + a loop of symlinks. Worktrees are added later as the task grows.

## Instant inspection

A human can browse any task's files, enter its R environment, and run tests at any time — without stopping the task or switching branches in the main checkout. Worktrees are always live; no "checkout" needed.

## Branch naming

Tasks use the existing `{issue}-{descriptor}` branch convention from AGENTS.md. Different repos within the same task may have different branch names and issue numbers.

## Task–spec link

Tasks correspond to design specs. The task ID is the spec topic name (e.g. `parallel-tasks` maps to `design/parallel-tasks/`).

## Persistence

Task state (worktrees, libraries, metadata) lives under `/workspace/` and persists across container rebuilds via the bind mount.

## Skill-driven

Task management is exposed as a Claude Code skill.

## Non-goals

- No dependency on rv, renv, or any external package manager. Plain symlinks + `.libPaths()` + `R CMD INSTALL`.
- No host-side tooling. Devcontainer only.
