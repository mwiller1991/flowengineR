#--------------------------------------------------------------------
#' Training Engine: Random Forest (RF)
#'
#' Fits a random forest model based on the provided formula, data, and weights using the `randomForest` package.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `formula`: A formula specifying the model structure.
#' - `data`: A data frame containing the training data (must include weights column if used).
#' - `sample_weight`: A numeric vector of observation weights.
#' - `ntree`: Number of trees to grow.
#' - `mtry`: Number of variables randomly sampled as candidates at each split.
#'
#' **Output (returned to wrapper):**
#' - A fitted model object of class `"randomForest"` as returned by `randomForest::randomForest()`.
#'
#' @seealso [wrapper_train_rf()]
#'
#' @param formula Model formula.
#' @param data Training data as data.frame.
#' @param sample_weight Numeric vector of observation weights.
#' @param ntree Number of trees to grow.
#' @param mtry Number of variables to sample at each split.
#'
#' @return A fitted model object of class `"randomForest"`.
#' @keywords internal
engine_train_rf <- function(formula, data, sample_weight, ntree, mtry) {
  args <- list(
    formula = formula,
    data = data,
    weights = sample_weight,
    ntree = ntree
  )
  if (!is.null(mtry)) args$mtry <- mtry
  
  do.call(randomForest::randomForest, args)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Training Engine: Random Forest (RF)
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' and invokes the RF training engine. Returns standardized output using `initialize_output_train()`.
#'
#' **Standardized Inputs:**
#' - `control$params$train$formula`: A formula specifying the model structure.
#' - `control$params$train$data`: Named list with training data (`original` and/or `normalized`).  
#'   → This list is automatically provided by the workflow, not by the user.
#' - `control$params$train$norm_data`: Logical flag indicating whether to use normalized data.
#' - `control$params$train$params`: Optional user-specified hyperparameters..
#'
#' **Engine-Specific Parameters (`control$params$train$params`):**
#' - `ntree` *(integer)*: Number of trees to grow (default: 500).
#' - `mtry` *(integer)*: Number of variables sampled at each split (default: sqrt(p)).
#' - `sample_weight` *(numeric vector)*: Observation weights (optional; defaults to equal weights).
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$train <- "train_rf"
#' control$params$train <- controller_training(
#'   formula = target ~ .,
#'   norm_data = TRUE,
#'   params = list(
#'     ntree = 100,
#'     mtry = 3
#'     # sample_weight = rep(1, nrow(train_data))  # optional
#'   )
#' )
#' ```
#' **Template Reference:**
#' See full template in `inst/templates_control/4_c_template_train_rf.R`
#'
#' **Standardized Output (returned to framework):**
#' - A structured list created by `initialize_output_train()`:
#'   - `model`: Fitted model object.
#'   - `model_type`: Identifier string ("rf").
#'   - `formula`: Used training formula.
#'   - `hyperparameters`: Merged hyperparameter set.
#'   - `specific_output`: Training duration and optional metadata.
#' 
#' @seealso 
#'   [engine_train_rf()],  
#'   [default_params_train_rf()],  
#'   [initialize_output_train()],  
#'   [controller_training()]
#'   Template: `inst/templates_control/4_c_template_train_rf.R`
#'
#' @param control A standardized control object (see `controller_training()`).
#' @return A standardized output list structured via `initialize_output_train()`.
#' @keywords internal
wrapper_train_rf <- function(control) {
  train_params <- control$params$train
  
  if (is.null(train_params$formula)) {
    stop("wrapper_train_rf: Missing required input: formula")
  }
  if (is.null(train_params$data)) {
    stop("wrapper_train_rf: Missing required input: data")
  }
  
  train_data <- select_training_data(train_params$norm_data, train_params$data)
  
  hyperparameters <- merge_with_defaults(train_params$params, default_params_train_rf())
  
  if (is.null(hyperparameters$sample_weight)) {
    hyperparameters$sample_weight <- rep(1, nrow(train_data))
  }
  train_data$sample_weight <- hyperparameters$sample_weight
  
  log_msg("[TRAIN] Starting RF training...", level = "info", control = control)
  start_time <- Sys.time()
  
  model <- engine_train_rf(
    formula = train_params$formula,
    data = train_data,
    sample_weight = hyperparameters$sample_weight,
    ntree = hyperparameters$ntree,
    mtry = hyperparameters$mtry
  )
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  log_msg(sprintf("[TRAIN] RF training finished in %.2f seconds.", training_time), level = "info", control = control)
  
  initialize_output_train(
    model = model,
    model_type = "rf",
    formula = train_params$formula,
    hyperparameters = hyperparameters,
    specific_output = list(training_time = training_time)
  )
}
#--------------------------------------------------------------------




#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Training Engine: RF
#'
#' Provides default parameters for the random forest training engine.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_training` function**, which include:
#'   - `formula`: A formula specifying the model structure.
#'   - `data`: A data frame containing the training data.
#'   
#' **Additional Parameters:**
#' - `ntree`: Number of trees to grow (default: 500).
#' - `mtry`: Number of variables sampled at each split (default: NULL → auto-detect by `randomForest()`).
#' - `sample_weight`: Vector of observation weights (optional).
#'
#' @seealso [wrapper_train_rf()]
#'
#' @return A list of default hyperparameters for the RF training engine.
#' @keywords internal
default_params_train_rf <- function() {
  list(
    ntree = 500,
    mtry = NULL,
    sample_weight = NULL  # If not set by user, will be set in the wrapper directly in the dataset
  )
}
#--------------------------------------------------------------------