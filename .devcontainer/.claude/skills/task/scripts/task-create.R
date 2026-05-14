args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) stop("Usage: Rscript task-create.R <id>")

id <- args[[1L]]
task_dir <- file.path("/workspace/.tasks", id)

if (dir.exists(task_dir)) stop("Task '", id, "' already exists.")

spec_dir <- file.path("/workspace/design", id)
if (!dir.exists(spec_dir)) stop("No spec found at ", spec_dir, ". Create a spec first.")

dir.create(file.path(task_dir, "library"), recursive = TRUE)
dir.create(file.path(task_dir, "worktrees"))

baseline <- list.dirs(
  "/workspace/.devcontainer/.library",
  full.names = TRUE,
  recursive = FALSE
)

for (pkg in baseline) {
  file.symlink(pkg, file.path(task_dir, "library", basename(pkg)))
}

writeLines(
  sprintf('.libPaths("%s")', file.path(task_dir, "library")),
  file.path(task_dir, ".Rprofile")
)

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
