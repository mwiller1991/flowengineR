#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Training Engine: Linear Model
#'
#' Fits a linear model using the specified formula and data.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `formula`: A formula specifying the model structure.
#' - `data`: A data frame containing the training data.
#'
#' **Output (returned to wrapper):**
#' - A fitted model object of class `"lm"` as returned by `stats::lm()`.
#'
#' @seealso [wrapper_train_lm()]
#'
#' @param formula Model formula.
#' @param data Training data as data.frame.
#'
#' @return A fitted model object of class `"lm"`.
#' @keywords internal
engine_train_lm <- function(formula, data) {
  lm(formula, data = data)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Training Engine: Linear Model (LM)
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' and invokes the LM training engine. Returns standardized output using `initialize_output_train()`.
#'
#' **Standardized Inputs:**
#' - `control$params$train$formula`: A formula specifying the model structure.
#' - `control$params$train$data`: Named list with training data (`original` and/or `normalized`).  
#'   → This list is automatically provided by the workflow, not by the user.
#' - `control$params$train$norm_data`: Logical flag indicating whether to use normalized data.
#' - `control$params$train$params`: Optional user-specified hyperparameters (none used by default).
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$train <- "train_lm"
#' control$params$train <- controller_train(
#'   formula = target ~ .,
#'   norm_data = TRUE
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/3_a_template_train_lm.R`
#'
#' **Standardized Output (returned to framework):**
#' - A structured list created by `initialize_output_train()`:
#'   - `model`: Fitted model object.
#'   - `model_type`: Identifier string ("lm").
#'   - `formula`: Used training formula.
#'   - `hyperparameters`: Merged hyperparameter set (typically empty).
#'   - `specific_output`: Training duration and optional metadata.
#'
#' @seealso 
#'   [engine_train_lm()],  
#'   [default_params_train_lm()],  
#'   [initialize_output_train()],  
#'   [controller_train()],  
#'   Template: `inst/templates_control/3_a_template_train_lm.R`
#'
#' @param control A standardized control object (see `controller_train()`).
#' @return A standardized output list structured via `initialize_output_train()`.
#' @keywords internal
wrapper_train_lm <- function(control) {
  train_params <- control$params$train  # Accessing the training parameters
  
  if (is.null(train_params$formula)) {
    stop("wrapper_train_lm: Missing required input: formula")
  }
  if (is.null(train_params$data)) {
    stop("wrapper_train_lm: Missing required input: data")
  }
  
  # Choose normalized or original data
  train_data <- select_training_data(train_params$norm_data, train_params$data)
    
  # Merge user-provided hyperparameters with defaults
  hyperparameters <- merge_with_defaults(train_params$params, default_params_train_lm())
  
  log_msg("[TRAIN] Starting LM training...", level = "info", control = control)
  
  # Track training time
  start_time <- Sys.time()
  
  # Call the specific training engine
  model <- engine_train_lm(train_params$formula, 
                           train_data)
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  log_msg(sprintf("[TRAIN] LM training finished in %.2f seconds.", training_time),
          level = "info", control = control)
  
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
#' @seealso [wrapper_train_lm()]
#'
#' @return A list of default hyperparameters for the training engine.
#' @keywords internal
default_params_train_lm <- function() {
  list()
}
#--------------------------------------------------------------------