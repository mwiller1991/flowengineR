#--------------------------------------------------------------------
### Controller for Split Inputs (supports multiple splitter engines)###
#--------------------------------------------------------------------
#' Controller for Split Inputs
#'
#' @param split_ratio The ratio for splitting the data (e.g., 0.7 for 70/30 split).
#' @param cv_folds The number of folds for cross-validation.
#' @param seed A random seed for reproducibility.
#' @return A list containing the split configuration.
#' @export
controller_split <- function(split_ratio = NULL, cv_folds = NULL, seed = NULL) {
  seed <- seed %||% control$global_seed %||% 123  # Default to global seed or 123 if none provided
  list(
    split_ratio = split_ratio,
    cv_folds = cv_folds,
    seed = seed
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Controller: Input for Training (supports multiple training engines) ###
#--------------------------------------------------------------------
#' Controller for Training Inputs
#'
#' @param formula A formula specifying the model structure.
#' @param data A data frame containing the training data.
#' @return A list containing the formula and data.
#' @export
controller_training <- function(formula, data = NULL) {
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
controller_fairness_post <- function(predictions = NULL, actuals = NULL) {
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
controller_evaluation <- function(eval_data = NULL, protected_name) {
  list(
    eval_data = eval_data,
    protected_name = protected_name
  )
}
#--------------------------------------------------------------------