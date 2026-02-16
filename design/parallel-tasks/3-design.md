# Parallel Tasks — Design

## Disk layout

Everything for a task lives under a single directory:

```
/workspace/.tasks/<task-id>/
  manifest.json
  .Rprofile
  library/
  worktrees/
    blockr.core/
    blockr.dplyr/
```

The task ID is the spec topic name (e.g. `parallel-tasks`), linking tasks to their design specs.

## Task lifecycle

1. **Create** (`/task create <id>`): Creates the directory structure with an empty manifest, a `library/` populated with symlinks to the baseline, and an `.Rprofile`. No packages yet.
2. **Add package** (`/task add <id> <pkg>`): Creates a git worktree for the package under `worktrees/`. The agent creates a GH issue, names the branch `{issue}-{descriptor}`, and updates the manifest. Optionally installs the package into the task library.
3. **Work**: The agent reads/edits files in the worktree paths, starts R sessions from the task directory (`.Rprofile` handles library setup), and calls `devtools::load_all()` as needed.
4. **Finish**: The agent commits, pushes, and opens PRs per repo. Each PR references its issue.
5. **Clean** (`/task clean <id>`): Removes worktrees via `git worktree remove`, deletes the task directory.

## Library isolation

At task creation, every package in `.devcontainer/.library/` is symlinked into `.tasks/<id>/library/`:

```bash
for pkg in /workspace/.devcontainer/.library/*/; do
  ln -s "$pkg" "/workspace/.tasks/<id>/library/$(basename "$pkg")"
done
```

When a task installs a modified package (e.g. `R CMD INSTALL` from a worktree), the symlink is replaced with the real installed package. Only packages that differ from baseline use disk space.

## .Rprofile

Written once at task creation, never updated:

```r
.libPaths("/workspace/.tasks/<id>/library")
```

Any R session started from the task directory automatically uses the task library. The agent calls `devtools::load_all()` on worktree packages explicitly as needed — that's not part of the `.Rprofile`.

## Manifest

Tracks per-task state in JSON:

```json
{
  "id": "parallel-tasks",
  "created": "2026-02-16T10:30:00Z",
  "status": "active",
  "spec": "design/parallel-tasks/",
  "packages": {
    "blockr.core": { "branch": "6-parallel", "issue": 6 },
    "blockr.dplyr": { "branch": "12-filter-fix", "issue": 12 }
  }
}
```

Branch and issue are filled in by the agent when it adds a package and creates the corresponding GH issue. The agent checks for existing open issues before creating new ones.

## The skill

A Claude Code skill at `.devcontainer/.claude/skills/task/SKILL.md` with helper scripts in `scripts/`.

The SKILL.md explains the system generically: what a manifest looks like, where worktrees and libraries live, how `.Rprofile` works, how to interact with GH (preference: MCP > gh CLI > gh REST API). The manifest holds task-specific data.

### Subcommands

| Command | What it does |
|---------|-------------|
| `create <id>` | Create task directory, symlink library, write `.Rprofile` and empty manifest |
| `add <id> <pkg>` | Create worktree, create GH issue/branch, update manifest |
| `list` | Show all tasks with status and packages |
| `info <id>` | Show detailed task info (paths, branches, issues) |
| `finish <id>` | Mark complete, remind to push/PR |
| `clean <id>` | Remove worktrees + task directory |

### Helper scripts

Shell scripts in `.devcontainer/.claude/skills/task/scripts/` handle the mechanical work (worktree creation, symlink loops, manifest updates). The skill tells the agent when to call them.

## Agent context

The agent doesn't need per-task documentation. The skill SKILL.md explains the system once; the agent looks up task-specific data from `manifest.json` as needed.

## Human inspection

Worktrees are always live. To inspect a task:
- Browse files: `ls /workspace/.tasks/<id>/worktrees/blockr.core/R/`
- Git status: `git -C /workspace/.tasks/<id>/worktrees/blockr.core status`
- Enter R env: start R from `/workspace/.tasks/<id>/` (`.Rprofile` sets library path)
