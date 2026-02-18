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

    porcelain <- system2(
      "git", c("-C", wt_dir, "status", "--porcelain"),
      stdout = TRUE, stderr = TRUE
    )
    if (length(porcelain) > 0L) message("  \u26a0 uncommitted changes")

    ahead <- tryCatch(
      system2(
        "git", c("-C", wt_dir, "rev-list", "--count", "@{u}..HEAD"),
        stdout = TRUE, stderr = TRUE
      ),
      warning = function(w) "?"
    )

    if (!identical(ahead, "0") && !identical(ahead, "?")) {
      message("  \u26a0 ", ahead, " unpushed commit(s)")
    }
  }

  if (!is.null(info$issue)) {

    repo_url <- system2(
      "git", c("-C", pkg_dir, "remote", "get-url", "origin"),
      stdout = TRUE, stderr = TRUE
    )
    repo <- sub(".*github\\.com[:/](.*?)(\\.git)?$", "\\1", repo_url)

    state <- tryCatch(
      system2(
        "gh", c("issue", "view", info$issue, "--repo", repo,
                 "--json", "state", "-q", ".state"),
        stdout = TRUE, stderr = TRUE
      ),
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
  message(
    "  git -C /workspace/", pkg, " worktree remove ",
    file.path(task_dir, "worktrees", pkg)
  )
}

message("  rm -rf ", task_dir)
