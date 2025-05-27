#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Fairness Post-Processing Engine: General Residual Adjustment
#'
#' Adjusts predictions by applying the mean residual to improve group-level fairness.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `predictions`: A numeric vector of predicted values.
#' - `actuals`: A numeric vector of observed target values.
#'
#' **Output (returned to wrapper):**
#' - A numeric vector of adjusted predictions.
#'
#' @param predictions A numeric vector of predicted values.
#' @param actuals A numeric vector of actual observed values.
#'
#' @return A numeric vector of adjusted predictions.
#' @export
engine_fairness_post_genresidual <- function(predictions, actuals) {
  residuals <- actuals - predictions
  predictions + mean(residuals)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Fairness Post-Processing Engine: General Residual Adjustment
#'
#' Validates and prepares standardized inputs, applies default parameters,
#' and invokes the general residual post-processing engine.
#' Returns a standardized output using `initialize_output_fairness_post()`.
#'
#' **Standardized Inputs:**
#' - `control$params$fairness_post$fairness_post_data$predictions`: Original prediction values.
#' - `control$params$fairness_post$fairness_post_data$actuals`: Observed target values.
#' - `control$params$fairness_post$protected_name`: Names of protected attributes.
#' - `control$params$fairness_post$params`: Optional engine-specific parameters (none used by this engine).
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_fairness_post()`:
#'   - `adjusted_predictions`: The fairness-adjusted predictions.
#'   - `method`: Set to `"general_residual"`.
#'   - `input_data`: Original prediction and actual data.
#'   - `protected_attributes`: Names of protected attributes.
#'   - `params`: Merged parameter list (empty for this engine).
#'   - `specific_output`: `NULL`.
#'
#' @param control A standardized control object (see `controller_fairness_post()`).
#' @return A standardized fairness post-processing output.
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
  NULL  # This engine does not require specific parameters -> for any other engine would be a list() necessary
}
#--------------------------------------------------------------------