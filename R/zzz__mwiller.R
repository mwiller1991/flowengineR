.onAttach <- function(libname, pkgname) {
  cli::cli_text("\n{.strong Welcome to flowengineR!}")
  cli::cli_text("{cli::symbol$star} Try: {.code flowengineR_start()} for an interactive tour")
  cli::cli_text("{cli::symbol$menu} Overview: {.code vignette(\"index\")} to surf through all vignettes")
  cli::cli_text("{cli::symbol$info} Get started: {.code vignette(\"getting_started\")} to dive in")
  cli::cli_text("{cli::symbol$play} First use: {.code run_workflow()} to start a pipeline")
  cli::cli_text("{cli::symbol$fancy_question_mark} Help: {.code ?run_workflow} for help")
}
