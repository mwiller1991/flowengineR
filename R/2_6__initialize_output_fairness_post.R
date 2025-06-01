#--------------------------------------------------------------------
### Output Initializer: Fairness Post-Processing ###
#--------------------------------------------------------------------
#' Output Initializer: Fairness Post-Processing Results
#'
#' Creates a standardized output structure for fairness post-processing engines
#' within the fairnessToolbox. This output format ensures that fairness-adjusted
#' predictions and relevant metadata are consistently handled.
#'
#' **Purpose:**
#' - Provides a uniform result object for all post-processing fairness engines.
#' - Enables downstream analysis, evaluation, and reporting.
#'
#' **Standardized Output:**
#' - `adjusted_predictions`: Vector of predictions after fairness adjustment.
#' - `method`: Identifier string (e.g., `"residual_shift"` or `"calibration"`).
#' - `input_data`: The original data used for fairness adjustment (typically includes predictions, actuals, group).
#' - `protected_attributes`: Names of the protected variables used during adjustment.
#' - `params`: Engine-specific parameters used in the fairness adjustment (optional).
#' - `specific_output`: Optional additional outputs such as diagnostics or intermediate steps.
#'
#' **Usage Example (inside a fairness post-processing engine):**
#' ```r
#' initialize_output_fairness_post(
#'   adjusted_predictions = adjusted_preds,
#'   method = "residual_shift",
#'   input_data = control$params$fairness_post$fairness_post_data,
#'   protected_attributes = control$params$fairness_post$protected_name,
#'   params = control$params$fairness_post$params,
#'   specific_output = list(residual_mean_diff = delta)
#' )
#' ```
#'
#' @param adjusted_predictions Numeric. Adjusted predictions after applying fairness logic.
#' @param method Character. Name of the fairness post-processing method used.
#' @param input_data Data frame. Input data used in fairness adjustment.
#' @param protected_attributes Character vector. Names of protected variables involved.
#' @param params Optional. Named list of parameters passed to the engine.
#' @param specific_output Optional. Engine-specific diagnostics or additional metadata.
#'
#' @return A standardized list to be returned by post-processing engines.
#' @export
initialize_output_fairness_post <- function(adjusted_predictions, method, input_data, protected_attributes, params = NULL, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    adjusted_predictions = adjusted_predictions,
    method = method,
    input_data = input_data,
    protected_attributes = protected_attributes
  )
  
  # Add optional fields if provided
  if (!is.null(params)) {
    output$params <- params
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------