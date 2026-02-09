.libPaths(c("/workspace/.library", .libPaths()))

options(
  repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"),
  HTTPUserAgent = sprintf(
    "R/%s R (%s)",
    getRversion(),
    paste(getRversion(), R.version[["platform"]], R.version[["arch"]], R.version[["os"]])
  ),
  shiny.port = 3838L,
  shiny.host = "0.0.0.0"
)

if (file.exists(".Rprofile.local")) {
  source(".Rprofile.local")
}
