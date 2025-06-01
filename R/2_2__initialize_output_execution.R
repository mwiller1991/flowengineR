#--------------------------------------------------------------------
### Output Initializer: Execution Engines ###
#--------------------------------------------------------------------
#' Output Initializer: Execution Engine Results
#'
#' Creates a standardized output structure for execution engines within the
#' fairnessToolbox framework. This ensures consistency across execution types
#' such as sequential runs, batchtools, SLURM arrays, and future distributed methods.
#'
#' **Purpose:**
#' - Ensures uniform downstream handling of execution results.
#' - Encodes both immediate and deferred (e.g., SLURM) execution strategies.
#'
#' **Standardized Output:**
#' - `execution_type`: Identifier string for the execution engine (e.g., `"sequential"`, `"slurm_array"`).
#' - `workflow_results`: List of results (from `run_workflow_single()`), or `NULL` if external execution.
#' - `params`: Optional engine-specific execution parameters.
#' - `specific_output`: Optional metadata (e.g., file paths, engine diagnostics).
#' - `continue_workflow`: Logical flag indicating whether the main workflow should proceed automatically.
#'
#' **Important Requirement:**
#' The names of `workflow_results` **must exactly match** the split identifiers in `split_output$splits`.
#' This is required for proper mapping and evaluation within `resume_fairness_workflow()`.
#'
#' **Usage Example (inside a wrapper):**
#' ```r
#' initialize_output_execution(
#'   execution_type = "sequential",
#'   workflow_results = result_list,
#'   params = control$params$execution$params,
#'   continue_workflow = TRUE
#' )
#' ```
#'
#' @param execution_type Character. Short label for the engine (e.g., "slurm_array", "batchtools").
#' @param workflow_results List of `run_workflow_single()` results (named to match splits), or `NULL` if deferred.
#' @param params Optional. List of engine-specific parameters.
#' @param specific_output Optional. Additional metadata or diagnostics.
#' @param continue_workflow Logical. Whether the fairness workflow should proceed after execution.
#'
#' @return A standardized list returned from all execution engines.
#' @export
initialize_output_execution <- function(execution_type, workflow_results, params = NULL, specific_output = NULL, continue_workflow = TRUE) {
  output <- list(
    execution_type = execution_type,
    workflow_results = workflow_results,
    continue_workflow = continue_workflow
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