#--------------------------------------------------------------------
### Output Initializer: Post-Processing ###
#--------------------------------------------------------------------
#' Output Initializer: Post-Processing Results
#'
#' Creates a standardized output structure for post-processing engines
#' within the flowengineR. This output format ensures that adjusted
#' predictions and relevant metadata are consistently handled.
#'
#' **Purpose:**
#' - Provides a uniform result object for all post-processing engines.
#' - Enables downstream analysis, evaluation, and reporting.
#'
#' **Standardized Output:**
#' - `adjusted_predictions`: Vector of predictions after adjustment.
#' - `method`: Identifier string (e.g., `"residual_shift"` or `"calibration"`).
#' - `input_data`: The original data used for adjustment (typically includes predictions, actuals, group).
#' - `protected_attributes`: Names of the protected variables used during adjustment.
#' - `params`: Engine-specific parameters used in the adjustment (optional).
#' - `specific_output`: Optional additional outputs such as diagnostics or intermediate steps.
#'
#' **Usage Example (inside a post-processing engine):**
#' ```r
#' initialize_output_postprocessing(
#'   adjusted_predictions = adjusted_preds,
#'   method = "residual_shift",
#'   input_data = control$params$postprocessing$postprocessing_data,
#'   protected_attributes = control$params$postprocessing$protected_name,
#'   params = control$params$postprocessing$params,
#'   specific_output = list(residual_mean_diff = delta)
#' )
#' ```
#'
#' @param adjusted_predictions Numeric. Adjusted predictions after applying logic.
#' @param method Character. Name of the post-processing method used.
#' @param input_data Data frame. Input data used in post-processing adjustment.
#' @param protected_attributes Character vector. Names of protected variables involved.
#' @param params Optional. Named list of parameters passed to the engine.
#' @param specific_output Optional. Engine-specific diagnostics or additional metadata.
#'
#' @return A standardized list to be returned by post-processing engines.
#' @export
initialize_output_postprocessing <- function(adjusted_predictions, method, input_data, protected_attributes, params = NULL, specific_output = NULL) {
  output <- list(
    adjusted_predictions = adjusted_predictions,
    method = method,
    input_data = input_data,
    protected_attributes = protected_attributes
  )
  if (!is.null(params)) output$params <- params
  if (!is.null(specific_output)) output$specific_output <- specific_output
  return(output)
}
#--------------------------------------------------------------------