#--------------------------------------------------------------------
### Controller: Input for Training (supports multiple training engines) ###
#--------------------------------------------------------------------
#' Controller for Training Inputs
#'
#' @param formula A formula specifying the model structure.
#' @param data A data frame containing the training data.
#' @return A list containing the formula and data.
#' @export
controller_training <- function(formula, data) {
  list(
    formula = formula,
    data = data
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Fairness Pre-Processing (supports multiple fairness pre-processing engines) ###
#--------------------------------------------------------------------
#' Controller for Fairness Pre-Processing Inputs
#'
#' @param data A data frame containing the input data.
#' @return A list containing the input data for fairness pre-processing.
#' @export
controller_fairness_pre <- function(data) {
  list(
    data = data
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Fairness Post-Processing (supports multiple fairness post-processing engines) ###
#--------------------------------------------------------------------
#' Controller for Fairness Post-Processing Inputs
#'
#' @param predictions A vector of predictions from the model.
#' @param actuals A vector of actual observed values.
#' @return A list containing predictions and actual values for post-processing.
#' @export
controller_fairness_post <- function(predictions, actuals) {
  list(
    predictions = predictions,
    actuals = actuals
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Evaluation (supports multiple evaluation engines) ###
#--------------------------------------------------------------------
#' Controller for Evaluation Inputs
#'
#' @param predictions A vector of predictions from the model.
#' @param actuals A vector of actual observed values.
#' @return A list containing predictions and actual values for evaluation.
#' @export
controller_evaluation <- function(predictions, actuals, protected_attribute, protected_name) {
  list(
    predictions = predictions,
    actuals = actuals,
    protected_attribute = protected_attribute,
    protected_name = protected_name
  )
}
#--------------------------------------------------------------------