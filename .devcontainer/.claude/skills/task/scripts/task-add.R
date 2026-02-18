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
