#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Mean Squared Error (MSE)
#'
#' Calculates the Mean Squared Error (MSE) between predicted and actual values.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `predictions`: A numeric vector of predicted values.
#' - `actuals`: A numeric vector of actual observed values.
#'
#' **Output (returned to wrapper):**
#' - A numeric value representing the MSE.
#'
#' @param predictions A numeric vector of predicted values.
#' @param actuals A numeric vector of actual observed values.
#'
#' @return A single numeric value: the mean squared error.
#' @export
engine_eval_mse <- function(predictions, actuals) {
  # Calculate Mean Squared Error between predictions and actual values
  mean((predictions - actuals)^2)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Evaluation Engine: Mean Squared Error (MSE)
#'
#' Validates and prepares standardized inputs, applies default parameters,
#' and invokes the MSE evaluation engine. Wraps the result using `initialize_output_eval()`.
#'
#' **Standardized Inputs:**
#' - `control$params$eval$eval_data$predictions`: Numeric vector of predicted values.
#' - `control$params$eval$eval_data$actuals`: Numeric vector of actual observed values.
#' - `control$params$eval$protected_attributes`: Names of protected attributes (optional, included in output).
#' - `control$params$eval$params$eval_mse`: Optional engine-specific parameters (not required by this engine).
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_eval()`:
#'   - `metrics`: Named list with entry `mse`, holding the MSE value.
#'   - `eval_type`: Set to `"mse_eval"`.
#'   - `input_data`: Original input used for evaluation.
#'   - `protected_attributes`: Passed through from control (if present).
#'   - `params`: Merged parameter list.
#'   - `specific_output`: `NULL`.
#'
#' @param control A standardized control object (see `controller_evaluation()`).
#' @return A standardized evaluation output object.
#' @export
wrapper_eval_mse <- function(control) {
  eval_params <- control$params$eval  # Accessing the evaluation parameters
  
  if (is.null(eval_params$eval_data$predictions)) {
    stop("wrapper_eval_mse: Missing required input: predictions")
  }
  if (is.null(eval_params$eval_data$actuals)) {
    stop("wrapper_eval_mse: Missing required input: actuals")
  }
  
  # Merge optional parameters with defaults
  #This is just for Test-Purposes -> This engine has no params
  specific_params <- eval_params$params[["eval_mse"]] %||% list()
  params <- merge_with_defaults(specific_params, default_params_eval_mse())
  
  # Call the specific evaluation engine
  mse <- engine_eval_mse(
    predictions = as.numeric(eval_params$eval_data$predictions),
    actuals = as.numeric(eval_params$eval_data$actuals)
  )
  
  # Standardized output
  initialize_output_eval(
    metrics = list(mse = mse),
    eval_type = "mse_eval",
    input_data = eval_params$eval_data,
    protected_attributes = eval_params$protected_attributes,
    params = params,  # No specific params for MSE evaluation
    specific_output = NULL  # No specific output for MSE evaluation
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Evaluation Engine: MSE
#'
#' Provides default parameters for the MSE evaluation engine.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' **Additional Parameters:**
#' - None for this engine; it relies entirely on the base fields from the controller.
#'
#' @return A list of default parameters for the MSE evaluation engine.
#' @export
default_params_eval_mse <- function() {
  #This is just for Test-Purposes
  list(weighting_factor = 1, adjustment_factor = 0)  # This engine does not require specific parameters -> for any other engine would be a list() necessary
}
#--------------------------------------------------------------------