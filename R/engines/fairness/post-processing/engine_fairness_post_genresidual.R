#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Fairness Post-Processing Engine: General Residual Adjustment
#'
#' @param predictions A vector of predictions from the model.
#' @param actuals A vector of actual observed values.
#' @return A vector of adjusted predictions.
#' @export
engine_fairness_post_genresidual <- function(predictions, actuals) {
  residuals <- actuals - predictions
  predictions + mean(residuals)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Fairness Post-Processing General Residual Adjustment
#'
#' @param control A list containing the fairness parameters and predictions.
#' @return A vector of adjusted predictions.
#' @export
wrapper_fairness_post_genresidual <- function(control) {
  fairness_post_params <- control$params$fairness_post  # Accessing the fairness parameters
  if (is.null(fairness_post_params$fairness_post_data$predictions)) {
    stop("wrapper_fairness_post_residual: Missing required input: predictions")
  }
  if (is.null(fairness_post_params$fairness_post_data$actuals)) {
    stop("wrapper_fairness_post_residual: Missing required input: actuals")
  }
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(fairness_post_params$params, default_params_fairness_post_genresidual())
  
  # Call the specific post-processing fairness engine
  adjusted_predictions <- engine_fairness_post_genresidual(fairness_post_params$fairness_post_data$predictions, fairness_post_params$fairness_post_data$actuals)
  
  # Ensure probabilities are within [0, 1] if output_type is "prob"
  if (control$output_type == "prob") {
    adjusted_predictions <- pmax(pmin(adjusted_predictions, 1), 0)
  }
  
  # Standardized output
  initialize_output_fairness_post(
    adjusted_predictions = adjusted_predictions,
    method = "general_residual",
    input_data = fairness_post_params$fairness_post_data,
    protected_attributes = fairness_post_params$protected_name,
    params = params,
    specific_output = NULL  # No specific output for general residual method
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Fairness Post-Processing Engines: General Residual Adjustment
#'
#' Provides default parameters for fairness post-processing engines. These parameters are specific to each engine and define optional values required for execution.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_fairness_post` function**, which include:
#'   - `protected_name`: Names of the protected attributes.
#' - **Additional Parameters:**
#'   - None for this engine; it relies entirely on the base fields from the controller.
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @return A list of default parameters for the fairness post-processing engine.
#' @export
default_params_fairness_post_genresidual <- function() {
  list()  # This engine does not require specific parameters
}
#--------------------------------------------------------------------