.libPaths(c("/workspace/.devcontainer/.library", .libPaths()))

options(
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
