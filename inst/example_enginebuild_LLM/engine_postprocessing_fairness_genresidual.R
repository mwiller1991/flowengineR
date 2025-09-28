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
#' @seealso [wrapper_postprocessing_fairness_genresidual()]
#'
#' @param predictions A numeric vector of predicted values.
#' @param actuals A numeric vector of actual observed values.
#'
#' @return A numeric vector of adjusted predictions.
#' @keywords internal
engine_postprocessing_fairness_genresidual <- function(predictions, actuals) {
  residuals <- actuals - predictions
  adjusted <- predictions + mean(residuals)
  pmax(adjusted, 0) #Floored at 0)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Fairness Post-Processing Engine: General Residual Adjustment
#'
#' Validates and prepares standardized inputs, applies default parameters,
#' and invokes the residual-based post-processing engine.
#' Returns a standardized output using `initialize_output_postprocessing()`.
#'
#' **Standardized Inputs:**
#' - `control$params$postprocessing$postprocessing_data$predictions`: Numeric vector of model predictions (injected by workflow).
#' - `control$params$postprocessing$postprocessing_data$actuals`: Numeric vector of true observed values (injected by workflow).
#' - `control$params$postprocessing$protected_name`: Character vector of protected attribute names (binary).  
#'   Auto-filled from `control$data$vars$protected_vars_binary` via `autofill_controllers_from_vars()`.
#' - `control$params$postprocessing$params`: Optional engine-specific parameters (not used here).
#'
#' **Binary Attribute Requirement:**
#' - All protected attributes listed in `protected_name` must be binary (e.g., 0/1, TRUE/FALSE).
#' - Post-processing engines in flowengineR are not designed for multi-class or continuous protected attributes.
#' - Binary transformation must be performed during setup (e.g. via `controller_vars(protected_vars_binary = ...)`).
#'
#' **Engine-Specific Parameters (`control$params$postprocessing$params`):**
#' - None. This engine performs a fixed residual adjustment and requires no tunable settings.
#' 
#' **Workflow Integration:**
#' - `protected_name` are **automatically filled** based on `control$data$vars`.
#' - These inputs must be respected by all engines but **do not need to be set manually** in the controller.
#' - This wrapper ensures these values are passed correctly to the engine.
#'
#' **Example Control Snippet:**
#' ```r
#' control$engine_select$postprocessing <- "postprocessing_fairness_genresidual"
#' control$params$postprocessing <- controller_postprocessing(
#'   params = list()
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/6_a_template_postprocessing_fairness_genresidual.R`
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_postprocessing()`:
#'   - `adjusted_predictions`: Residual-adjusted prediction vector.
#'   - `method`: `"general_residual"`.
#'   - `input_data`: List with `predictions` and `actuals`.
#'   - `protected_attributes`: Names of protected attributes used (binary).
#'   - `params`: Final parameter list (empty for this engine).
#'   - `specific_output`: `NULL`
#'
#' @seealso 
#'   [engine_postprocessing_fairness_genresidual()],  
#'   [default_params_postprocessing_fairness_genresidual()],  
#'   [initialize_output_postprocessing()],  
#'   [controller_postprocessing()],  
#'   Template: `inst/templates_control/6_a_template_postprocessing_fairness_genresidual.R`
#'
#' @param control A standardized control object (must include `control$data$vars` and a valid `control$params$postprocessing`).
#' @return A standardized fairness post-processing output.
#' @keywords internal
wrapper_postprocessing_fairness_genresidual <- function(control) {
  postprocessing_params <- control$params$postprocessing  # Accessing the fairness parameters
  if (is.null(postprocessing_params$postprocessing_data$predictions)) {
    stop("wrapper_postprocessing_fairness_genresidual: Missing required input: predictions")
  }
  if (is.null(postprocessing_params$postprocessing_data$actuals)) {
    stop("wrapper_postprocessing_fairness_genresidual: Missing required input: actuals")
  }
  
  log_msg("[POST] Starting general residual adjustment...", level = "info", control = control)
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(postprocessing_params$params, default_params_postprocessing_fairness_genresidual())
  
  # Call the specific post-processing fairness engine
  adjusted_predictions <- engine_postprocessing_fairness_genresidual(postprocessing_params$postprocessing_data$predictions, postprocessing_params$postprocessing_data$actuals)
  
  # Ensure probabilities are within [0, 1] if output_type is "prob"
  if (control$settings$output_type == "prob") {
    adjusted_predictions <- pmax(pmin(adjusted_predictions, 1), 0)
  }
  
  log_msg("[POST] Adjustment complete.", level = "info", control = control)
  
  # Standardized output
  initialize_output_postprocessing(
    adjusted_predictions = adjusted_predictions,
    method = "general_residual",
    input_data = postprocessing_params$postprocessing_data,
    protected_attributes = postprocessing_params$protected_name,
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
#' - These parameters are **not covered by the base fields in the `controller_postprocessing` function**, which include:
#'   - `protected_name`: Names of the protected attributes.
#' - **Additional Parameters:**
#'   - None for this engine; it relies entirely on the base fields from the controller.
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @seealso [wrapper_postprocessing_fairness_genresidual()]
#'
#' @return A list of default parameters for the fairness post-processing engine.
#' @keywords internal
default_params_postprocessing_fairness_genresidual <- function() {
  list()
}
#--------------------------------------------------------------------