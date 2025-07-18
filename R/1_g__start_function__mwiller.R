#' Launch the interactive start menu for flowengineR
#'
#' This function offers an interactive menu to explore flowengineR.
#'
#' @importFrom utils menu str
#'
#' @export
flowengineR_start <- function() {
  cat("\nWelcome to flowengineR - your modular workflow engine for data science.\n\n")
  
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
        paste(cli::symbol$cross, "Exit")
      )
    )
    
    switch(choice,
           {
             message("\nRunning example workflow...\n")
             results_example <- run_workflow()
             assign("results_example", results_example, envir = .GlobalEnv)
           },
           {
             message("\nOpening overview vignette 'index'...\n")
             print(utils::vignette("index"))
           },
           {
             message("\nOpening vignette 'getting_started'...\n")
             print(utils::vignette("getting_started"))
           },
           {
             message("\nAvailable engines saved to object 'engine_list':\n")
             engine_list <- list_registered_engines()
             assign("engine_list", engine_list, envir = .GlobalEnv)
             print(names(engine_list))
           },
           {
             message("\nOpening help for run_workflow()...\n")
             print(utils::help("run_workflow", package = "flowengineR"))
           },
           {
             message("\nStructure of control-object:\n")
             control_example <- complete_control_with_defaults(list())
             assign("control_example", control_example, envir = .GlobalEnv)
             print(str(control_example))
           },
           {
             message("\nGoodbye! Have fun with flowengineR!\n")
             break
           }
    )
  }
}
