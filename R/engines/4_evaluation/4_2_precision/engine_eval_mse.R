#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Mean Squared Error
#'
#' Calculates the Mean Squared Error (MSE) between predictions and actual values.
#'
#' **Inputs:**
#' - `predictions`: A numeric vector of predicted values.
#' - `actuals`: A numeric vector of actual observed values.
#'
#' **Outputs (passed to wrapper):**
#' - `metrics`: A list containing the MSE value.
#'
#' @param predictions A numeric vector of predicted values.
#' @param actuals A numeric vector of actual observed values.
#' @return A list containing the MSE metric.
#' @export
engine_eval_mse <- function(predictions, actuals) {
  # Calculate Mean Squared Error between predictions and actual values
  mean((predictions - actuals)^2)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Evaluation: Mean Squared Error
#'
#' Handles input validation, calls the MSE evaluation engine, and creates standardized output.
#'
#' @param control A list containing the evaluation parameters and data.
#' @return A standardized list containing the evaluation results.
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