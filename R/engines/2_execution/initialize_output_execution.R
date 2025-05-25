#--------------------------------------------------------------------
### helper for execution output ###
#--------------------------------------------------------------------
#' Initialize Output for Execution Engines
#'
#' Wraps results from execution engines into a standardized structure.
#'
#' **Standardized Output:**
#' - `execution_type`: Type of execution engine (e.g., "sequential", "slurm")
#' - `workflow_results`: List of workflow results (can be NULL if deferred)
#' - `params`: Parameters used by the execution engine (optional)
#' - `specific_output`: Engine-specific outputs (optional)
#' - `continue_workflow`: Logical flag whether the workflow should continue immediately
#'
#' @param execution_type A string describing the engine type.
#' @param workflow_results A list of workflow results, or NULL if externally executed.
#' @param params A list of parameters used during execution.
#' @param specific_output Optional engine-specific output metadata.
#' @param continue_workflow Logical flag indicating whether workflow should proceed immediately.
#'
#' @return A standardized list for execution output.
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