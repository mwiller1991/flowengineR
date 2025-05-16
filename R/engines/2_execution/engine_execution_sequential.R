#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Sequential Split Execution
#'
#' Applies `run_workflow_single()` over all data splits sequentially.
#'
#' **Inputs:**
#' - `control`: The full control object.
#' - `split_output`: Output from the splitter engine, including all splits.
#'
#' **Outputs (passed to wrapper):**
#' - A list of individual workflow results, one per split.
#'
#' @param control A list containing all workflow parameters and inputs.
#' @param split_output A list of splits from the splitter engine.
#' @return A list of results from each `run_workflow_single()` call.
#' @export
engine_execution_sequential <- function(control, split_output) {
  lapply(split_output$splits, function(split) {
    control$data$train <- split$train
    control$data$test  <- split$test
    run_workflow_single(control)
  })
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Sequential Split Execution
#'
#' Wraps the `engine_execution_sequential` function for standardized use in the workflow.
#'
#' @param control The control object used throughout the workflow.
#' @param split_output The result of the splitter engine.
#'
#' @return A list of results from all splits.
#' @export
wrapper_execution_sequential <- function(control, split_output) {
  # Merge optional parameters with defaults (if needed in future engines)
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_sequential())
  
  workflow_results <- engine_execution_sequential(control, split_output)
  
  # Standardized output structure
  initialize_output_execution(
    execution_type = "sequential",
    workflow_results = workflow_results,
    params = params,
    specific_output = list(n_splits = length(split_output))
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Sequential Split Execution
#'
#' Provides default parameters for execution engines. These parameters are specific to sequential execution
#' and currently not required.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for future use.
#'
#' @return A list of default parameters for the execution engine.
#' @export
default_params_execution_sequential <- function() {
  list()  # No parameters required for sequential execution
}
#--------------------------------------------------------------------