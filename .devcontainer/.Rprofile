.libPaths(c("/workspace/.devcontainer/.library", .libPaths()))

options(
  # Do NOT hardcode lintr.linter_file: it forces every local lintr run to this
  # one config and overrides each package's checked-in .lintr, so local results
  # never match CI (CI reads the package's own .lintr). Leaving it unset lets
  # lintr auto-discover each repo's .lintr, matching the remote checks.
  # lintr.linter_file = "/workspace/.devcontainer/.lintr",
  repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"),
  HTTPUserAgent = sprintf(
    "R/%s R (%s)",
    getRversion(),
    paste(getRversion(), R.version[["platform"]], R.version[["arch"]], R.version[["os"]])
  )
)

if (interactive()) {
  options(
    shiny.port = 3838L,
    shiny.host = "0.0.0.0",
    browser = function(url) message("App running at ", url)
  )
}

if (file.exists("/workspace/.devcontainer/.Rprofile.local")) {
  source("/workspace/.devcontainer/.Rprofile.local")
}
