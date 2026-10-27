#' Launch the interactive start menu for flowengineR
#'
#' Offers an interactive console menu to explore flowengineR: run the
#' example workflow, open the main vignettes, list the registered engines
#' or inspect the structure of the control object. The menu is only
#' available in interactive sessions.
#'
#' @return Invisibly, a named list with the objects created in the menu:
#'   `results_example` (item 1), `engine_list` (item 4) and
#'   `control_example` (item 6). Only items that were chosen are included,
#'   so the list is empty if none of them was used. Assign the result to
#'   keep the objects, e.g. `start <- flowengineR_start()`.
#'
#' @examples
#' if (interactive()) {
#'   start <- flowengineR_start()
#'   names(start)
#' }
#'
#' @importFrom utils menu str
#'
#' @export
flowengineR_start <- function() {
  out <- list()
  
  if (!interactive()) {
    message("flowengineR_start() is only available in interactive sessions.")
    return(invisible(out))
  }
  
  message("\nWelcome to flowengineR - your modular workflow engine for data science.")
  message("Tip: use 'start <- flowengineR_start()' to keep the objects created here.\n")
  
  repeat {
    choice <- menu(
      title = "Where would you like to start?",
      choices = c(
        paste(cli::symbol$play, "Run example workflow"),
        paste(cli::symbol$menu, "Open 'Index' vignette for overview of all vignettes"),
        paste(cli::symbol$info, "Open 'Getting Started' vignette"),
        paste(cli::symbol$record, "List available engines"),
        paste(cli::symbol$fancy_question_mark, "Help for run_workflow()"),
        paste(cli::symbol$star, "Show structure of control-object"),
        paste(cli::symbol$info, "Open 'How to build custom Engines' vignette"),
        paste(cli::symbol$info, "Open 'How to use LLM-Engine-Builder' vignette"),
        paste(cli::symbol$cross, "Exit")
      )
    )
    
    # 0 = menu cancelled, 9 = "Exit"
    if (choice %in% c(0L, 9L)) {
      message("\nGoodbye! Have fun with flowengineR!\n")
      break
    }
    
    switch(choice,
           {
             message("\nRunning example workflow...\n")
             out$results_example <- run_workflow()
             message("\nResults returned as 'results_example'.\n")
           },
           {
             message("\nOpening overview vignette 'index'...\n")
             print(utils::vignette("index", package = "flowengineR"))
           },
           {
             message("\nOpening vignette 'getting_started'...\n")
             print(utils::vignette("getting_started", package = "flowengineR"))
           },
           {
             message("\nAvailable engines (returned as 'engine_list'):\n")
             out$engine_list <- list_registered_engines()
             print(names(out$engine_list))
           },
           {
             message("\nOpening help for run_workflow()...\n")
             print(utils::help("run_workflow", package = "flowengineR"))
           },
           {
             message("\nStructure of control-object (returned as 'control_example'):\n")
             out$control_example <- complete_control_with_defaults(list())
             str(out$control_example)
           },
           {
             message("\nOpening vignette 'How to build custom Engines'...\n")
             print(utils::vignette("how_to_build_custom_engine", package = "flowengineR"))
           },
           {
             message("\nOpening vignette 'How to use LLM-Engine-Builder'...\n")
             print(utils::vignette("how_to_use_llm_engine_builder", package = "flowengineR"))
           }
    )
  }
  
  invisible(out)
}