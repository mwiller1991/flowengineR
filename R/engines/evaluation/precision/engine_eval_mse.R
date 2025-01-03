#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Evaluation Engine: Mean Squared Error
#'
#' @param predictions A vector of predictions from the model.
#' @param actuals A vector of actual observed values.
#' @return The mean squared error between predictions and actuals.
#' @export
engine_eval_mse <- function(predictions, actuals) {
  # Calculate Mean Squared Error between predictions and actual values
  mean((predictions - actuals)^2)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Evaluation
#'
#' @param control A list containing predictions and actual values.
#' @return The result of the evaluation metric.
#' @export
wrapper_eval_mse <- function(control) {
  eval_params <- control$params$eval  # Accessing the evaluation parameters
  if (is.null(eval_params$eval_data$predictions)) {
    stop("wrapper_eval_mse: Missing required input: predictions")
  }
  if (is.null(eval_params$eval_data$actuals)) {
    stop("wrapper_eval_mse: Missing required input: actuals")
  }
  
  # Call the specific evaluation engine
  engine_eval_mse(eval_params$eval_data$predictions, eval_params$eval_data$actuals)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
default_params_eval_mse <- function() {
  list()  # MSE evaluation does not require specific parameters
}
#--------------------------------------------------------------------