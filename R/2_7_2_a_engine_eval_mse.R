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
#' @seealso [wrapper_eval_mse()]
#'
#' @param predictions A numeric vector of predicted values.
#' @param actuals A numeric vector of actual observed values.
#'
#' @return A single numeric value: the mean squared error.
#' @keywords internal
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
#' - `control$params$eval$eval_data$predictions`: Numeric vector of predicted values (injected by workflow).
#' - `control$params$eval$eval_data$actuals`: Numeric vector of actual values (injected by workflow).
#' - `control$params$eval$protected_attributes`: Names of protected attributes (optional; included in output).
#' - `control$params$eval$params$eval_mse`: Optional engine-specific parameters.
#'
#' **Engine-Specific Parameters (`control$params$eval$params$eval_mse`):**
#' - None. This engine has no tunable settings and simply computes the MSE.
#'
#' **Variable Handling:**
#' - This engine does **not** require `protected_name` to be binary.
#' - Protected attributes are passed through for consistency and may be used in reporting.
#'
#' **Example Control Snippet:**
#' ```
#' control$evaluation <- "eval_mse"
#' control$params$eval <- controller_evaluation(
#'   params = list()
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/7_2_a_template_eval_mse.R`
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_eval()`:
#'   - `metrics`: Named list with entry `mse` (numeric).
#'   - `eval_type`: `"mse_eval"`.
#'   - `input_data`: Evaluation input (predictions + actuals).
#'   - `protected_attributes`: Passed through from control (optional, not used).
#'   - `params`: Empty list.
#'   - `specific_output`: `NULL`.
#'
#' @seealso 
#'   [engine_eval_mse()],  
#'   [default_params_eval_mse()],  
#'   [initialize_output_eval()],  
#'   [controller_evaluation()],  
#'   Template: `inst/templates_control/7_2_a_template_eval_mse.R`
#'
#' @param control A standardized control object (see `controller_evaluation()`).
#' @return A standardized evaluation output object.
#' @keywords internal
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
  
  log_msg(sprintf("[EVAL] MSE evaluation complete. MSE = %.6f", mse), level = "info", control = control)
  
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
#' @seealso [wrapper_eval_mse()]
#'
#' @return A list of default parameters for the MSE evaluation engine.
#' @keywords internal
default_params_eval_mse <- function() {
  list()
}
#--------------------------------------------------------------------