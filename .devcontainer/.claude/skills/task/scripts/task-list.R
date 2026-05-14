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
