#' Regenerate documentation recursively (incl. subfolders in R/)
#'
#' Run this if you use subfolders inside R/
#'
roxygen2::roxygenise(
  package.dir = ".",
  roclets = c("namespace", "rd"),
  load_code = function(...) roxygen2:::load_code("R", recursive = TRUE)
)