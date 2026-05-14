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
