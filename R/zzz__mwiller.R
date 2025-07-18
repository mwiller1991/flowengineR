.onAttach <- function(libname, pkgname) {
  msg <- c(
    cli::format_inline("\n{.strong Welcome to flowengineR!}"),
    cli::format_inline("{cli::symbol$star} Try: {.code flowengineR_start()} for an interactive tour"),
    cli::format_inline("{cli::symbol$menu} Overview: {.code vignette(\"index\")} to surf through all vignettes"),
    cli::format_inline("{cli::symbol$info} Get started: {.code vignette(\"getting_started\")} to dive in"),
    cli::format_inline("{cli::symbol$play} First use: {.code run_workflow()} to start a pipeline"),
    cli::format_inline("{cli::symbol$fancy_question_mark} Help: {.code ?run_workflow} for help")
  )
  packageStartupMessage(paste(msg, collapse = "\n"))
}
