#' Launch the interactive start menu for flowengineR
#'
#' This function offers an interactive menu to explore flowengineR.
#'
#' @export
flowengineR_start <- function() {
  cat("\n🌊 Welcome to flowengineR – your modular workflow engine for data science.\n\n")
  
  repeat {
    choice <- menu(
      title = "Where would you like to start?",
      choices = c(
        "Run example workflow",
        "Open 'Getting Started' vignette",
        "List available engines",
        "Help for run_workflow()",
        "Show structure of control-object",
        "xit"
      )
    )
    
    switch(choice,
           {
             message("\nRunning example workflow...\n")
             results_example <- run_workflow()
             assign("results_example", results_example, envir = .GlobalEnv)
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
             utils::help("run_workflow", package = "flowengineR")
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
