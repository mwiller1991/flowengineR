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
#' @param predictions A vector of predictions from the model.
#' @return A vector of adjusted predictions.
#' @export
wrapper_fairness_post_genresidual <- function(control) {
  fairness_params <- control$params$fairness  # Accessing the fairness parameters
  if (is.null(fairness_params$predictions)) {
    stop("wrapper_fairness_post_residual: Missing required input: predictions")
  }
  if (is.null(fairness_params$actuals)) {
    stop("wrapper_fairness_post_residual: Missing required input: actuals")
  }
  
  # Call the specific post-processing fairness engine
  adjusted_predictions <- engine_fairness_post_genresidual(fairness_params$predictions, fairness_params$actuals)
  
  # Ensure probabilities are within [0, 1] if output_type is "prob"
  if (control$output_type == "prob") {
    adjusted_predictions <- pmax(pmin(adjusted_predictions, 1), 0)
  }
  
  return(adjusted_predictions)
}
#--------------------------------------------------------------------