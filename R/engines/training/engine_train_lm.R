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
  if (is.null(train_params$data)) {
    stop("wrapper_train_lm: Missing required input: data")
  }
  
  # Merge user-provided hyperparameters with defaults
  hyperparameters <- merge_with_defaults(train_params$params, default_params_train_lm())
  
  # Track training time
  start_time <- Sys.time()
  
  # Call the specific training engine
  model <- engine_train_lm(train_params$formula, train_params$data)
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  # Standardized output
  initialize_output_train(
    model = model,
    model_type = "lm",
    formula = train_params$formula,
    hyperparameters = hyperparameters,
    specific_output = list(training_time = training_time)
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default hyperparams ###
#--------------------------------------------------------------------
#' Default Parameters for Training Engines: LM
#'
#' Provides default parameters for training engines. These parameters are specific to each engine and define optional values required for execution.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_training` function**, which include:
#'   - `formula`: A formula specifying the model structure.
#'   - `data`: A data frame containing the training data.
#' - **Additional Parameters:**
#'   - None for this engine; it relies entirely on the base fields from the controller.
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @return A list of default hyperparameters for the training engine.
#' @export
default_params_train_lm <- function() {
  NULL  # This engine does not require specific parameters -> for any other engine would be a list() necessary
}
#--------------------------------------------------------------------