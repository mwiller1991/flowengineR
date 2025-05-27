#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Training Engine: Generalized Linear Model (GLM)
#'
#' Fits a generalized linear model based on the provided formula, data, weights, and family distribution.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `formula`: A formula specifying the model structure.
#' - `data`: A data frame containing the training data.
#' - `weights`: A numeric vector of observation weights.
#' - `family`: A GLM family object (e.g., `gaussian()` or `binomial()`).
#'
#' **Output (returned to wrapper):**
#' - A fitted model object of class `"glm"` as returned by `stats::glm()`.
#'
#' @param formula Model formula.
#' @param family GLM family object.
#' @param data Training data as data.frame.
#' @param weights Numeric vector of observation weights.
#'
#' @return A fitted model object of class `"glm"`.
#' @export
engine_train_glm <- function(formula, family, data, weights) {
  glm(formula = formula, family = family, data = data, weights = weights)
}
#--------------------------------------------------------------------

#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Training Engine: Generalized Linear Model (GLM)
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' and invokes the GLM training engine. Returns standardized output using `initialize_output_train()`.
#'
#' **Standardized Inputs:**
#' - `control$params$train$formula`: A formula specifying the model structure.
#' - `control$params$train$data`: Named list with training data (`original` and/or `normalized`).
#' - `control$params$train$norm_data`: Logical flag indicating whether to use normalized data.
#' - `control$params$train$params`: Optional user-specified hyperparameters (e.g., `weights`, `family`).
#'
#' **Standardized Output (returned to framework):**
#' - A structured list created by `initialize_output_train()`:
#'   - `model`: Fitted model object.
#'   - `model_type`: Identifier string ("glm").
#'   - `formula`: Used training formula.
#'   - `hyperparameters`: Merged hyperparameter set.
#'   - `specific_output`: Training duration and optional metadata.
#'
#' @param control A standardized control object (see `controller_training()`).
#' @return A standardized output list structured via `initialize_output_train()`.
#' @export
wrapper_train_glm <- function(control) {
  train_params <- control$params$train  # Accessing the training parameters
  
  if (is.null(train_params$formula)) {
    stop("wrapper_train_glm: Missing required input: formula")
  }
  if (is.null(train_params$data)) {
    stop("wrapper_train_glm: Missing required input: data")
  }
  
  # Choose normalized or original data
  train_data <- select_training_data(train_params$norm_data, train_params$data)
  
  # Merge user-provided hyperparameters with defaults
  hyperparameters <- merge_with_defaults(train_params$params, default_params_train_glm())
  
  # Extract weights from params or set equal weights
  hyperparameters$weights <- hyperparameters$weights %||% rep(1, nrow(train_data))
  
  # Track training time
  start_time <- Sys.time()
  
  # Call the specific training engine
  model <- engine_train_glm(
    formula = train_params$formula,
    family = hyperparameters$family,
    data = train_data,
    weights = hyperparameters$weights
  )
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  # Standardized output
  initialize_output_train(
    model = model,
    model_type = "glm",
    formula = train_params$formula,
    hyperparameters = hyperparameters,
    specific_output = list(training_time = training_time)
  )
}
#--------------------------------------------------------------------

#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Training Engines: GLM
#'
#' Provides default parameters for training engines. These parameters are specific to each engine and define optional values required for execution.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_training` function**, which include:
#'   - `formula`: A formula specifying the model structure.
#'   - `data`: A data frame containing the training data.
#'   
#' - **Additional Parameters:**
#'   - `weights`: A vector of weights for the training data. Must have same length as train dataset (default: equal weights -> in Wrapper).
#'   - `family`: The family of the GLM (default: Gaussian).
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @return A list of default hyperparameters for the training engine.
#' @export
default_params_train_glm <- function() {
  list(
    weights = NULL,  # If not set by user, will be set in the wrapper directly in the dataset
    family = gaussian()  # Default family: Gaussian
  )
}
#--------------------------------------------------------------------