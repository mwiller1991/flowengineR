#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Linear Model Training Engine
#'
#' @param formula A formula specifying the model structure.
#' @param data A data frame containing the training data.
#' @return A trained linear model object.
#' @export
engine_train_lm <- function(formula, data) {
  lm(formula, data = data)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Linear Model Training
#'
#' @param control A list containing the training formula and data.
#' @return A list containing the trained model and its summary.
#' @export
wrapper_train_lm <- function(control) {
  train_params <- control$params$train  # Accessing the training parameters
  if (is.null(train_params$formula)) {
    stop("wrapper_train_lm: Missing required input: formula")
  }
  if (is.null(train_params$dataset)) {
    stop("wrapper_train_lm: Missing required input: data")
  }
  
  # Call the specific training engine
  model <- engine_train_lm(train_params$formula, train_params$data$train)
  
  # Return the trained model
  list(model = model)
}
#--------------------------------------------------------------------