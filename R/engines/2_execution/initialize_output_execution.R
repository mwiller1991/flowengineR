#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Sequential Split Execution
#'
#' Applies `run_workflow_single()` over all data splits sequentially.
#'
#' **Inputs:**
#' - `control_list`: A list of fully prepared control objects (one per split).
#'
#' **Output:**
#' - A list of results from each split execution.
#'
#' @param control_list A list of control objects, each with data$train and data$test already set.
#' @return A list of results from `run_workflow_single()` per split.
#' @export
engine_execution_sequential <- function(control_list) {
  lapply(control_list, run_workflow_single)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Sequential Split Execution
#'
#' Prepares one control object per split and delegates execution to the engine.
#'
#' @param control A control object containing all configurations.
#' @param split_output Output from the splitter engine.
#'
#' @return A standardized execution output containing all results.
#' @export
wrapper_execution_sequential <- function(control, split_output) {
  # Merge optional execution parameters
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_sequential())
  
  # Create a separate control object per split
  control_list <- lapply(split_output$splits, function(split) {
    modified_control <- control
    modified_control$data$train <- split$train
    modified_control$data$test  <- split$test
    return(modified_control)
  })
  
  results <- engine_execution_sequential(control_list)
  
  # Standardized output structure
  return(initialize_output_execution(
    execution_type = "sequential",
    results = results,
    params = params,
    specific_output = list(n_splits = length(control_list))
  ))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Sequential
#'
#' Defines optional parameters for the sequential execution engine.
#'
#' @return A named list of default parameters (currently empty).
#' @export
default_params_execution_sequential <- function() {
  list()
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### helper for execution output ###
#--------------------------------------------------------------------
#' Initialize Output for Execution Engines
#'
#' Wraps results from execution engines into a standardized structure.
#'
#' @param execution_type A string describing the engine type (e.g., "sequential").
#' @param results A list of workflow results, one per split.
#' @param params Optional parameters used by the engine.
#' @param specific_output Optional engine-specific metadata.
#'
#' @return A standardized list for execution output.
#' @export
initialize_output_execution <- function(execution_type, workflow_results, params = NULL, specific_output = NULL) {
  output <- list(
    execution_type = execution_type,
    workflow_results = workflow_results
  )
  
  if (!is.null(params)) {
    output$params <- params
  }
  
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------