#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Sequential Split Execution
#'
#' Executes the workflow sequentially over all predefined data splits by calling `run_workflow_singlesplitloop()` for each split.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `control`: The full control object with all configurations.
#' - `split_output`: Output from the splitter engine, containing a list of splits.
#'
#' **Output (returned to wrapper):**
#' - A list of results, each returned from one `run_workflow_singlesplitloop()` call per split.
#'
#' @param control A list containing all workflow parameters and inputs.
#' @param split_output A list of splits from the splitter engine.
#'
#' @seealso [wrapper_execution_basic_sequential()]
#'
#' @return A list of results from each `run_workflow_singlesplitloop()` call.
#' @keywords internal
engine_execution_basic_sequential <- function(control, split_output) {
  # Loop over each data split and run the workflow sequentially
  lapply(split_output$splits, function(split) {
    control$data$train <- split$train
    control$data$test  <- split$test
    run_workflow_singlesplitloop(control)
  })
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Sequential Split Execution
#'
#' Executes the workflow sequentially over all predefined data splits by calling `run_workflow_singlesplitloop()` for each.
#' This engine is ideal for simple setups or debugging when parallelization is not required.
#'
#' **Standardized Inputs:**
#' - `control`: The full control object containing configuration and input data.
#' - `split_output`: Output from the splitter engine containing all data splits.
#' - `control$params$execution$params`: Optional execution-specific parameters (currently unused).
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' This engine currently accepts no parameters. The parameter list may be used for future extensions.
#'
#' **Notes:**
#' - Splits are processed one by one in a single R session.
#' - No parallelization or external dependencies required.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$execution <- "execution_basic_sequential"
#' control$params$execution <- controller_execution(
#'   params = list()  # No parameters needed
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/2_1_a_template_control_execution_basic_sequential.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_execution()`:
#' - `execution_type`: `"basic_sequential"`
#' - `workflow_results`: List of results from each split (output of `run_workflow_singlesplitloop()`)
#' - `params`: Engine parameters (merged default and user-defined)
#' - `continue_workflow`: `TRUE` (execution completed within wrapper)
#' - `specific_output`: List with:
#'     - `n_splits`: Number of executed splits
#'
#' @seealso 
#'   [engine_execution_basic_sequential()],  
#'   [default_params_execution_basic_sequential()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_1_a_template_control_execution_basic_sequential.R`  
#'   Helper: [show_template()]
#'
#' @param control A standardized control object.
#' @param split_output A list of data splits created by the splitter engine.
#'
#' @return A standardized execution result list.
#' @keywords internal

wrapper_execution_basic_sequential <- function(control, split_output) {
  # Merge optional parameters with defaults (if needed in future engines)
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_basic_sequential())
  
  log_msg(sprintf(
    "[EXECUTION] Starting sequential execution over %d split(s)...",
    length(split_output$splits)
  ), level = "info", control = control)
  
  workflow_results <- engine_execution_basic_sequential(control, split_output)
  
  # Standardized output structure
  initialize_output_execution(
    execution_type = "basic_sequential",
    workflow_results = workflow_results,
    params = params,
    continue_workflow = TRUE,
    specific_output = list(n_splits = length(split_output))
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Sequential
#'
#' Provides default parameters for the `execution_basic_sequential` engine.
#' This engine executes all splits one after another in a single R session.
#'
#' **Purpose:**
#' - Defines engine-specific parameters (if any) that can be customized.
#' - Ensures a consistent interface across all execution engines.
#'
#' **Default Parameters:**
#' - (None required for sequential execution; returns an empty list.)
#'
#' @seealso [wrapper_execution_basic_sequential()]
#'
#' @return An empty named list of parameters for the sequential execution engine.
#' @keywords internal
default_params_execution_basic_sequential <- function() {
  list()
}
#--------------------------------------------------------------------