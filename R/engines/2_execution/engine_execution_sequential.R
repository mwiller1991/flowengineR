#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Sequential Split Execution
#'
#' Executes the workflow sequentially over all predefined data splits by calling `run_workflow_single()` for each split.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `control`: The full control object with all configurations.
#' - `split_output`: Output from the splitter engine, containing a list of splits.
#'
#' **Output (returned to wrapper):**
#' - A list of results, each returned from one `run_workflow_single()` call per split.
#'
#' @param control A list containing all workflow parameters and inputs.
#' @param split_output A list of splits from the splitter engine.
#'
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
#' Prepares standardized inputs and invokes the sequential execution engine. Wraps results using `initialize_output_execution()`.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Optional execution-related parameters (currently unused).
#' - `control`: Full control object with configuration and data.
#' - `split_output`: Output list from the splitter engine, containing all data splits.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "sequential".
#'   - `workflow_results`: List of per-split results.
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: Set to `TRUE`.
#'   - `specific_output`: Metadata such as number of splits.
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list containing the results from the splitter engine.
#'
#' @return A standardized execution result list.
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
#' Provides default parameters for the `execution_sequential` engine.
#' This engine executes all splits one after another in a single R session.
#'
#' **Purpose:**
#' - Defines engine-specific parameters (if any) that can be customized.
#' - Ensures a consistent interface across all execution engines.
#'
#' **Default Parameters:**
#' - (None required for sequential execution; returns an empty list.)
#'
#' @return An empty named list of parameters for the sequential execution engine.
#' @export
default_params_execution_sequential <- function() {
  list()
}
#--------------------------------------------------------------------