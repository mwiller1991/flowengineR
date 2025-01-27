#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Training Engine: Generalized Linear Model (GLM)
#'
#' Fits a generalized linear model using the specified formula, data, weights, and family.
#'
#' **Inputs:**
#' - `formula`: The formula specifying the model structure.
#' - `data`: The data frame containing the training data.
#' - `weights`: A vector of weights for the training data.
#' - `family`: The family of the GLM (e.g., Gaussian, Binomial).
#'
#' **Outputs (passed to wrapper):**
#' - `model`: The trained GLM object.
#' - `model_type`: A string identifying the model type ("glm").
#' - `specific_output`: Training-specific outputs such as training time.
#'
#' @param formula The formula specifying the model structure.
#' @param data The data frame containing the training data.
#' @param family The family of the GLM (e.g., Gaussian, Binomial).
#' @return A list containing the trained model and metadata.
#' @export
engine_train_glm <- function(formula, family, data, weights) {
  glm(formula = formula, family = family, data = data, weights = weights)
}
#--------------------------------------------------------------------

#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Generalized Linear Model Training
#'
#' @param control A list containing the training formula, data, and parameters.
#' @return A list containing the trained model and its metadata.
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
  train_data$weights <- hyperparameters$weights
  
  # Track training time
  start_time <- Sys.time()
  
  # Call the specific training engine
  model <- engine_train_glm(train_params$formula, 
                            hyperparameters$family, 
                            train_data, 
                            train_params$data$weights
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