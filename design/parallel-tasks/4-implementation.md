# Parallel Tasks — Implementation

## Files to create

```
.devcontainer/.claude/skills/task/
  SKILL.md
  scripts/
    task-create.R
    task-add.R
    task-list.R
    task-info.R
    task-clean.R
```

## Scripts

All scripts are R, live in `.devcontainer/.claude/skills/task/scripts/`, and operate on `/workspace/.tasks/`. The agent calls them via `Rscript <path> <args>`.

### task-create.R

```r
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) stop("Usage: Rscript task-create.R <id>")

id <- args[[1L]]
task_dir <- file.path("/workspace/.tasks", id)

if (dir.exists(task_dir)) stop("Task '", id, "' already exists.")

spec_dir <- file.path("/workspace/design", id)
if (!dir.exists(spec_dir)) stop("No spec found at ", spec_dir, ". Create a spec first.")

dir.create(file.path(task_dir, "library"), recursive = TRUE)
dir.create(file.path(task_dir, "worktrees"))

# Symlink baseline packages
baseline <- list.dirs("/workspace/.devcontainer/.library", full.names = TRUE, recursive = FALSE)
for (pkg in baseline) {
  file.symlink(pkg, file.path(task_dir, "library", basename(pkg)))
}

# .Rprofile
writeLines(
  sprintf('.libPaths("%s")', file.path(task_dir, "library")),
  file.path(task_dir, ".Rprofile")
)

# Manifest
jsonlite::write_json(
  list(
    id = id,
    created = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    status = "active",
    spec = file.path("design", id),
    packages = setNames(list(), character())
  ),
  file.path(task_dir, "manifest.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

message("Task '", id, "' created at ", task_dir)
message("Start R from ", task_dir, " to use the task library.")
```

### task-add.R

Creates a worktree for a package. Branch name is required — the agent determines it after creating a GH issue.

```r
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3L) stop("Usage: Rscript task-add.R <id> <pkg> <branch>")

id <- args[[1L]]
pkg <- args[[2L]]
branch <- args[[3L]]

task_dir <- file.path("/workspace/.tasks", id)
pkg_dir <- file.path("/workspace", pkg)
wt_dir <- file.path(task_dir, "worktrees", pkg)

if (!dir.exists(task_dir)) stop("Task '", id, "' does not exist.")
if (!dir.exists(file.path(pkg_dir, ".git"))) stop("'", pkg, "' is not a git repo at ", pkg_dir)
if (dir.exists(wt_dir)) stop("Package '", pkg, "' already added to task '", id, "'.")

system2("git", c("-C", pkg_dir, "worktree", "add", wt_dir, "-b", branch))

manifest_path <- file.path(task_dir, "manifest.json")
manifest <- jsonlite::read_json(manifest_path)
manifest$packages[[pkg]] <- list(branch = branch, issue = NULL)
jsonlite::write_json(manifest, manifest_path, pretty = TRUE, auto_unbox = TRUE)

message("Added '", pkg, "' to task '", id, "' on branch '", branch, "'")
message("Worktree: ", wt_dir)
```

The agent updates the `issue` field in the manifest after creating the GH issue.

### task-list.R

```r
task_base <- "/workspace/.tasks"

manifests <- Sys.glob(file.path(task_base, "*", "manifest.json"))

if (length(manifests) == 0L) {
  message("No tasks.")
  quit("no")
}

rows <- lapply(manifests, function(path) {
  m <- jsonlite::read_json(path)
  pkgs <- paste(names(m$packages), collapse = ", ")
  if (pkgs == "") pkgs <- "(none)"
  data.frame(ID = m$id, Status = m$status, Packages = pkgs)
})

cat(format(do.call(rbind, rows)), sep = "\n")
```

### task-info.R

```r
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) stop("Usage: Rscript task-info.R <id>")

id <- args[[1L]]
task_dir <- file.path("/workspace/.tasks", id)

if (!dir.exists(task_dir)) stop("Task '", id, "' does not exist.")

m <- jsonlite::read_json(file.path(task_dir, "manifest.json"))

message("Task:    ", m$id)
message("Status:  ", m$status)
message("Created: ", m$created)
message("Spec:    ", m$spec %||% "(none)")
message()

if (length(m$packages) > 0L) {
  message("Packages:")
  for (pkg in names(m$packages)) {
    info <- m$packages[[pkg]]
    message("  ", pkg, ": branch=", info$branch, ", issue=#", info$issue)
    message("    worktree: ", file.path(task_dir, "worktrees", pkg))
  }
} else {
  message("No packages added yet.")
}

message()
message("Library: ", file.path(task_dir, "library"))
message("R env:   start R from ", task_dir)
```

### task-clean.R

Reports the state of each package (uncommitted changes, unpushed commits, open GH issues). Prints removal commands for the agent to review with the user.

```r
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) stop("Usage: Rscript task-clean.R <id>")

id <- args[[1L]]
task_dir <- file.path("/workspace/.tasks", id)

if (!dir.exists(task_dir)) stop("Task '", id, "' does not exist.")

m <- jsonlite::read_json(file.path(task_dir, "manifest.json"))

message("Task: ", id, "\n")

for (pkg in names(m$packages)) {

  info <- m$packages[[pkg]]
  pkg_dir <- file.path("/workspace", pkg)
  wt_dir <- file.path(task_dir, "worktrees", pkg)

  message("--- ", pkg, " (branch: ", info$branch, ") ---")

  if (dir.exists(wt_dir)) {

    porcelain <- system2("git", c("-C", wt_dir, "status", "--porcelain"),
                         stdout = TRUE, stderr = TRUE)
    if (length(porcelain) > 0L) message("  \u26a0 uncommitted changes")

    ahead <- tryCatch(
      system2("git", c("-C", wt_dir, "rev-list", "--count", "@{u}..HEAD"),
              stdout = TRUE, stderr = TRUE),
      warning = function(w) "?"
    )
    if (!identical(ahead, "0") && !identical(ahead, "?")) {
      message("  \u26a0 ", ahead, " unpushed commit(s)")
    }
  }

  if (!is.null(info$issue)) {
    repo_url <- system2("git", c("-C", pkg_dir, "remote", "get-url", "origin"),
                        stdout = TRUE, stderr = TRUE)
    repo <- sub(".*github\\.com[:/](.*?)(\\.git)?$", "\\1", repo_url)
    state <- tryCatch(
      system2("gh", c("issue", "view", info$issue, "--repo", repo,
                       "--json", "state", "-q", ".state"),
              stdout = TRUE, stderr = TRUE),
      error = function(e) "unknown"
    )
    message("  Issue #", info$issue, ": ", state)
  }

  message()
}

message("---")
message("This will remove all worktrees and the task directory.")
message("The agent should confirm with the user before proceeding.\n")
message("Removal commands:")
for (pkg in names(m$packages)) {
  message("  git -C /workspace/", pkg, " worktree remove ",
          file.path(task_dir, "worktrees", pkg))
}
message("  rm -rf ", task_dir)
```

The script prints state and removal commands. The agent reviews with the user, then executes. Closing GH issues is left to the agent (via `gh issue close`) after user confirmation.

## SKILL.md

```yaml
---
name: task
description: |
  Manage parallel development tasks with isolated source and library
  environments. Use to create, list, inspect, or clean up tasks.
argument-hint: "<create|add|list|info|clean> [args...]"
---
```

The skill body covers:

### Subcommand dispatch

Parse `$ARGUMENTS` to determine the subcommand and call the corresponding R script from `.devcontainer/.claude/skills/task/scripts/` via `Rscript`.

### System overview (for agent context)

Explain the task system so the agent understands:

- Each task lives at `/workspace/.tasks/<id>/`.
- `library/` contains symlinks to baseline packages; installing a package replaces the symlink.
- `worktrees/<pkg>/` contains git worktrees — this is where the agent edits source.
- For packages not in the task, use `/workspace/<pkg>/` (read-only).
- Start R sessions from the task directory so `.Rprofile` sets `.libPaths()`.
- Call `devtools::load_all()` on worktree packages as needed.

### Adding a package — agent workflow

When the agent needs to modify a package not yet in the task:

1. Check for an existing open GH issue on that repo that matches the work. If found, confirm with user.
2. If no existing issue, create one (prefer MCP, fall back to `gh` CLI).
3. Name the branch `{issue}-{descriptor}`.
4. Run `Rscript .devcontainer/.claude/skills/task/scripts/task-add.R <id> <pkg> <branch>`.
5. Update the manifest's issue field.

### Cleaning — agent workflow

1. Run `Rscript .devcontainer/.claude/skills/task/scripts/task-clean.R <id>` to see the state.
2. Show the user what's still open (unpushed commits, open issues, open PRs).
3. Ask the user what to do: close issues? discard uncommitted changes? proceed?
4. On confirmation, close issues via `gh issue close`, then execute the removal commands printed by the script.

### Installing modified packages

When changes to a worktree package need to be visible to other packages (e.g. blockr.dplyr depends on blockr.core):

```bash
R CMD INSTALL --no-multiarch --library=/workspace/.tasks/<id>/library /workspace/.tasks/<id>/worktrees/blockr.core
```

The `--library` flag directs the install to the task library, replacing the blockr.core symlink with the real installed package.

## Edge cases

### R session must start from task directory

`.Rprofile` is only picked up if R is started from `/workspace/.tasks/<id>/`. If the agent starts R from elsewhere, `.libPaths()` won't be set correctly. The skill should remind the agent of this.

Alternative: the agent can set the lib path explicitly:

```r
.libPaths("/workspace/.tasks/<id>/library")
```

### Two tasks modifying the same package

Each gets its own branch and worktree. Git worktrees enforce that no two worktrees share a branch. Merge conflicts are handled at PR review time.

### Worktree on an existing branch

If the branch already exists (e.g. from a previous task or manual work), `git worktree add -b` will fail. The agent should handle this by using `git worktree add <path> <existing-branch>` without `-b`.

### Symlink replacement on install

`R CMD INSTALL` removes the target directory before writing. If the target is a symlink, `rm` removes the symlink (not the target). The installed package then gets written as a real directory. Baseline remains untouched.

### Baseline library updates

If someone installs a new package into the baseline (`.devcontainer/.library/`), existing tasks won't see it because their `library/` only has symlinks created at task creation time. The agent can fix this by adding the missing symlink:

```r
file.symlink(
  "/workspace/.devcontainer/.library/newpkg",
  "/workspace/.tasks/<id>/library/newpkg"
)
```

This is a rare edge case — baseline changes are infrequent.

## Verification plan

1. Create a task: `/task create test-task`
2. Verify directory structure: `manifest.json`, `.Rprofile`, `library/` with symlinks.
3. Add a package: `/task add test-task blockr.core 99-test`
4. Verify worktree exists at `.tasks/test-task/worktrees/blockr.core/` on branch `99-test`.
5. Start R from `.tasks/test-task/`, confirm `.libPaths()` points to task library.
6. Modify a file in the worktree, confirm main checkout at `/workspace/blockr.core/` is unaffected.
7. Run `R CMD INSTALL --library=... --no-multiarch` on the worktree package, confirm symlink replaced with real package.
8. Run `devtools::check()` from the worktree directory.
9. Clean up: `/task clean test-task`, verify worktrees and directories removed.
