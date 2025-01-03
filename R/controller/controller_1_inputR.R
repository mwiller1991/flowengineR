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
#' Creates standardized input for training engines. Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `formula`: A formula specifying the model structure.
#' - `params`: Optional hyperparameters for the training engine.
#'
#' @param formula A formula specifying the model structure.
#' @param hyperparameters A list of additional hyperparameters for the training engine.
#'
#' @return A standardized list for training input.
#' @export
controller_training <- function(formula, params = NULL) {
  list(
    formula = formula,
    params = params
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
#' Creates standardized input for fairness post-processing engines. 
#' Ensures all necessary fields are included for processing.
#'
#' **Standardized Input:**
#' - `protected_name`: Names of the protected attributes.
#' - `params`: Optional parameters for the fairness post-processing engine.
#'
#' @param fairness_post_data A data frame containing predictions, actuals, and protected attributes.
#' @param protected_name A character vector of protected attribute names.
#' @param params A list of additional parameters for the fairness engine.
#'
#' @return A standardized list for fairness post-processing.
#' @export
controller_fairness_post <- function(fairness_post_data, protected_name, params = list()) {
  list(
    protected_name = protected_name,
    params = params
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