#--------------------------------------------------------------------
### Output Initializer: Evaluation Engine ###
#--------------------------------------------------------------------
#' Output Initializer: Evaluation Engine Results
#'
#' Creates a standardized output structure for evaluation engines within the fairnessToolbox.
#' Ensures compatibility with result aggregation, reporting, and publishing mechanisms.
#'
#' **Purpose:**
#' - Guarantees a consistent structure for all evaluation outputs.
#' - Enables downstream aggregation and comparability across engines.
#'
#' **Standardized Output:**
#' - `metrics`: Named list of metric values computed by the evaluation engine.
#' - `eval_type`: Identifier string for the evaluation engine (e.g., `"mse_eval"`).
#' - `input_data`: Raw input data used for evaluation (e.g., predictions, actuals, protected attributes).
#' - `protected_attributes`: Vector of protected group names (optional).
#' - `params`: Parameter list passed to the evaluation engine (optional).
#' - `specific_output`: Engine-specific metadata or intermediate diagnostics (optional).
#'
#' **Usage Example (inside an evaluation engine):**
#' ```r
#' initialize_output_eval(
#'   metrics = list(mse = 0.053),
#'   eval_type = "mse_eval",
#'   input_data = control$params$eval$eval_data,
#'   protected_attributes = control$vars$protected_vars_binary,
#'   params = control$params$eval$params[["mse_eval"]],
#'   specific_output = list(residuals = resid(model))
#' )
#' ```
#'
#' @param metrics Named list. Metric values returned by the evaluation engine.
#' @param eval_type Character. Short engine identifier.
#' @param input_data Data frame. Raw data used in evaluation (typically includes predictions and actuals).
#' @param protected_attributes Optional. Character vector of protected attributes used in evaluation.
#' @param params Optional. List of parameters passed to the engine.
#' @param specific_output Optional. Additional diagnostic or metadata output.
#'
#' @return A standardized list containing evaluation results.
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