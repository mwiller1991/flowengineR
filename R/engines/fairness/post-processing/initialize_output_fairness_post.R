#--------------------------------------------------------------------
### helper for trainer-engines ###
#--------------------------------------------------------------------
#' Initialize Output for Fairness Post-Processing
#'
#' Creates standardized output for fairness post-processing engines. 
#' Ensures consistency across all engines of this type.
#'
#' **Standardized Output:**
#' - `adjusted_predictions`: Numeric vector of adjusted predictions.
#' - `method`: Character string describing the fairness adjustment method.
#' - `input_data`: The original input data used for processing.
#' - `protected_attributes`: Protected attributes used during processing.
#' - `params`: Parameters used for the fairness adjustment, if any.
#' - `specific_output`: Engine-specific outputs, if any.
#'
#' @param adjusted_predictions Numeric vector of adjusted predictions.
#' @param method Character string describing the fairness adjustment method.
#' @param input_data The original input data used for processing.
#' @param protected_attributes Protected attributes used during processing.
#' @param params Optional parameters used for the fairness adjustment.
#' @param specific_output Optional engine-specific outputs.
#'
#' @return A standardized list containing the output fields.
#' @export
initialize_output_fairness_post <- function(adjusted_predictions, method, input_data, protected_attributes, params, specific_output = NULL) {
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