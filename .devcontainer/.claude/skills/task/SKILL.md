---
name: task
description: |
  Manage parallel development tasks with isolated source and library
  environments. Use to create, list, inspect, or clean up tasks.
  Use when the user says 'task create', 'task list', 'task add',
  'task info', 'task clean', or 'task finish'.
argument-hint: "<create|add|list|info|finish|clean> [args...]"
---

# Task Skill

Manage parallel tasks. Each task gets isolated git worktrees and an isolated R package library so multiple agents (or an agent and a human) can work independently.

## Subcommand dispatch

Parse `$ARGUMENTS` to determine the subcommand and arguments. The scripts live at:

```
.devcontainer/.claude/skills/task/scripts/
```

Call them via `Rscript <script-path> <args>`.

| Input pattern | Script to call |
|---|---|
| `create <id>` | `task-create.R <id>` |
| `add <id> <pkg> <branch>` | `task-add.R <id> <pkg> <branch>` |
| `list` | `task-list.R` |
| `info <id>` | `task-info.R <id>` |
| `clean <id>` | See cleaning workflow below |
| `finish <id>` | See finish workflow below |

If `$ARGUMENTS` is empty or unrecognized, show available subcommands.

## System overview

Each task lives at `/workspace/.tasks/<id>/`:

```
/workspace/.tasks/<id>/
  manifest.json       # task metadata (packages, branches, issues)
  .Rprofile           # sets .libPaths() to task library
  library/            # symlinks to baseline; installs replace symlinks
  worktrees/
    blockr.core/      # git worktree (only packages the task touches)
```

Key concepts:

- **Library isolation**: `library/` starts as symlinks to every package in `.devcontainer/.library/`. When a task installs a package (e.g. via `R CMD INSTALL`), the symlink is replaced with the real installed package. Baseline stays untouched.
- **Source isolation**: `worktrees/<pkg>/` are git worktrees — the agent edits source here, not in `/workspace/<pkg>/`.
- **Unmodified packages**: For packages not in the task, use `/workspace/<pkg>/` (read-only from the task's perspective).
- **R sessions**: Start R from `/workspace/.tasks/<id>/` so `.Rprofile` sets `.libPaths()`. Alternatively, set it explicitly: `.libPaths("/workspace/.tasks/<id>/library")`.
- **Loading packages**: Call `devtools::load_all()` on worktree packages as needed.
- **Task–spec link**: Task IDs correspond to spec topic names. A task cannot be created without an existing spec at `design/<id>/`.

## Adding a package — agent workflow

When the agent needs to modify a package not yet in the task:

1. Check for an existing open GH issue on that repo that matches the work. Use GH MCP tools if available, fall back to `gh` CLI, then GH REST API. If an issue is found, confirm with the user before reusing it.
2. If no existing issue, create one.
3. Name the branch `{issue}-{descriptor}` (per AGENTS.md conventions).
4. Run: `Rscript .devcontainer/.claude/skills/task/scripts/task-add.R <id> <pkg> <branch>`
5. Update the manifest's `issue` field for that package (edit `manifest.json` directly).

## Installing modified packages

When changes to a worktree package need to be visible to other packages (e.g. blockr.dplyr depends on blockr.core), install the modified package into the task library:

```bash
R CMD INSTALL --no-multiarch --library=/workspace/.tasks/<id>/library /workspace/.tasks/<id>/worktrees/blockr.core
```

The `--library` flag directs the install to the task library, replacing the symlink with the real installed package.

## Finish workflow

When the agent is done with a task:

1. Ensure all changes are committed and pushed in each worktree.
2. Open PRs per repo, each referencing its GH issue. Use `Closes #<issue>` in the PR body.
3. Update the manifest: set `"status": "completed"`.

## Cleaning workflow

1. Run `Rscript .devcontainer/.claude/skills/task/scripts/task-clean.R <id>` to see current state.
2. The script reports: uncommitted changes, unpushed commits, open GH issues.
3. Show this to the user and ask what to do:
   - Close open issues? (use `gh issue close`)
   - Discard uncommitted changes?
   - Proceed with cleanup?
4. On confirmation, execute the removal commands printed by the script.

## Edge cases

- **R started outside task dir**: `.Rprofile` won't be picked up. Set `.libPaths()` explicitly.
- **Two tasks modifying the same package**: Fine — each gets its own branch and worktree. Merge conflicts are handled at PR time.
- **Existing branch**: If `git worktree add -b` fails because the branch exists, use `git worktree add <path> <existing-branch>` without `-b`.
- **New baseline package**: If a package is added to `.devcontainer/.library/` after task creation, add the symlink manually: `file.symlink("/workspace/.devcontainer/.library/newpkg", "/workspace/.tasks/<id>/library/newpkg")`.
