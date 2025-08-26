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
#' - `sample_weight`: A numeric vector of observation weights.
#' - `family`: A GLM family object (e.g., `gaussian()` or `binomial()`).
#'
#' **Output (returned to wrapper):**
#' - A fitted model object of class `"glm"` as returned by `stats::glm()`.
#'
#' @seealso [wrapper_train_glm()]
#'
#' @param formula Model formula.
#' @param family GLM family object.
#' @param data Training data as data.frame.
#' @param sample_weight Numeric vector of observation weights.
#'
#' @return A fitted model object of class `"glm"`.
#' @keywords internal
engine_train_glm <- function(formula, family, data, sample_weight) {
  glm(formula = formula, family = family, data = data, weights = sample_weight)
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
#'   → This list is automatically provided by the workflow, not by the user.
#' - `control$params$train$norm_data`: Logical flag indicating whether to use normalized data.
#' - `control$params$train$params`: Optional user-specified hyperparameters.
#'
#' **Engine-Specific Parameters (`control$params$train$params`):**
#' - `family` *(function)*: A GLM family function, e.g., `gaussian()` (default), `binomial()`, `poisson()`.
#' - `sample_weight` *(numeric vector)*: Observation weights (optional; defaults to equal weights).
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$train <- "train_glm"
#' control$params$train <- controller_training(
#'   formula = target ~ .,
#'   norm_data = TRUE,
#'   params = list(
#'     family = binomial()
#'     # sample_weight = rep(1, nrow(train_data))  # optional if weighted learning is used
#'   )
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/4_b_template_train_glm.R`
#'
#' **Standardized Output (returned to framework):**
#' - A structured list created by `initialize_output_train()`:
#'   - `model`: Fitted model object.
#'   - `model_type`: Identifier string ("glm").
#'   - `formula`: Used training formula.
#'   - `hyperparameters`: Merged hyperparameter set.
#'   - `specific_output`: Training duration and optional metadata.
#'
#' @seealso 
#'   [engine_train_glm()],  
#'   [default_params_train_glm()],  
#'   [initialize_output_train()],  
#'   [controller_training()],  
#'   Template: `inst/templates_control/4_b_template_train_glm.R`
#'
#' @param control A standardized control object (see `controller_training()`).
#' @return A standardized output list structured via `initialize_output_train()`.
#' @keywords internal
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
  if (is.null(hyperparameters$sample_weight)) {
    hyperparameters$sample_weight <- rep(1, nrow(train_data))
  }
  train_data$sample_weight <- hyperparameters$sample_weight
  
  log_msg("[TRAIN] Starting GLM training...", level = "info", control = control)
  
  # Track training time
  start_time <- Sys.time()
  
  # Call the specific training engine
  model <- engine_train_glm(
    formula = train_params$formula,
    family = hyperparameters$family,
    data = train_data,
    sample_weight = hyperparameters$sample_weight
  )
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  log_msg(sprintf("[TRAIN] GLM training finished in %.2f seconds.", training_time),
          level = "info", control = control)
  
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
#'   - `sample_weight`: A vector of weights for the training data. Must have same length as train dataset (default: equal weights -> in Wrapper).
#'   - `family`: The family of the GLM (default: Gaussian).
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @seealso [wrapper_train_glm()]
#'
#' @return A list of default hyperparameters for the training engine.
#' @keywords internal
default_params_train_glm <- function() {
  list(
    sample_weight = NULL,  # If not set by user, will be set in the wrapper directly in the dataset
    family = gaussian()  # Default family: Gaussian
  )
}
#--------------------------------------------------------------------