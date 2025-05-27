#--------------------------------------------------------------------
### helper for eval-engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Evaluation Engines
#'
#' Creates standardized output for evaluation engines. 
#' Ensures consistency across all evaluation engines.
#'
#' **Standardized Output:**
#' - `metrics`: A named list of evaluation metrics and their values.
#' - `eval_type`: A string specifying the type of the evaluation engine (e.g., "mse_eval", "fairness_eval").
#' - `input_data`: The original input data used for evaluation.
#' - `protected_attributes`: Protected attributes used during evaluation (optional).
#' - `params`: Parameters used for the evaluation (optional).
#' - `specific_output`: Optional engine-specific outputs.
#'
#' @param metrics A named list of evaluation metrics and their values.
#' @param eval_type A string specifying the type of the evaluation engine.
#' @param input_data The original input data used for evaluation.
#' @param protected_attributes Protected attributes used during evaluation (default is NULL).
#' @param params Parameters used for the evaluation (default is list()).
#' @param specific_output Optional engine-specific outputs (default is NULL).
#'
#' @return A standardized list containing the output fields for the evaluation engine.
#' @export
initialize_output_eval <- function(metrics, eval_type, input_data, protected_attributes = NULL, params  = NULL, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    metrics = metrics,
    eval_type = eval_type,
    input_data = input_data
  )
  
  # Add optional fields if provided
  if (!is.null(protected_attributes)) {
    output$protected_attributes <- protected_attributes
  }
  if (!is.null(params)) {
    output$params <- params
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------