#--------------------------------------------------------------------
### helper for fairness-in engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for In-Processing Engines
#'
#' Creates standardized output for in-processing engines. 
#' Ensures consistency across all in-processing engines.
#'
#' **Standardized Output:**
#' - `adjusted_model`: The adjusted main model after in-processing.
#' - `model_type`: A string specifying the type of the model (e.g., "randomForest", "glm").
#' - `predictions`: Numeric vector of predictions, typically made after in-processing adjustments.
#' - `params`: A list of parameters used during in-processing, if applicable.
#' - `specific_output`: Optional engine-specific outputs, such as adversarial performance metrics.
#'
#' @param adjusted_model The adjusted main model object after in-processing.
#' @param model_type A string specifying the type of the model (e.g., "randomForest", "glm").
#' @param predictions Numeric vector of predictions, typically made after in-processing adjustments (default is NULL).
#' @param params A list of parameters used during in-processing (default is NULL).
#' @param specific_output A list of engine-specific optional outputs (default is NULL).
#'
#' @return A standardized list containing the output fields for the in-processing engine.
#' @export
initialize_output_fairness_in <- function(adjusted_model, model_type, predictions = NULL, params = NULL, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    adjusted_model = adjusted_model,
    model_type = model_type,
    predictions = predictions
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