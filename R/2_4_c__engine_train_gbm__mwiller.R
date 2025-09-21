#--------------------------------------------------------------------
#' Training Engine: Gradient Boosting Machine (GBM)
#'
#' Fits a GBM model based on the provided formula, data, and weights using the `gbm` package.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `formula`: A formula specifying the model structure.
#' - `data`: A data frame containing the training data (must include weights column if used).
#' - `sample_weight`: A numeric vector of observation weights.
#' - `distribution`: Loss distribution (e.g., "gaussian", "bernoulli").
#' - `n.trees`: Number of boosting iterations (trees).
#' - `interaction.depth`: Depth of each tree.
#' - `shrinkage`: Learning rate.
#' - `n.minobsinnode`: Minimum observations in terminal nodes.
#' - `bag.fraction`: Subsampling fraction for stochastic gradient boosting.
#' - `train.fraction`: Fraction of data used for training (rest for internal OOB-like eval).
#'
#' **Output (returned to wrapper):**
#' - A fitted model object of class `"gbm"` as returned by `gbm::gbm()`.
#'
#' @seealso [wrapper_train_gbm()]
#'
#' @param formula Model formula.
#' @param data Training data as data.frame.
#' @param sample_weight Numeric vector of observation weights.
#' @param distribution GBM loss distribution.
#' @param n.trees Number of boosting iterations.
#' @param interaction.depth Tree depth.
#' @param shrinkage Learning rate.
#' @param n.minobsinnode Minimum obs per terminal node.
#' @param bag.fraction Subsample fraction per tree.
#' @param train.fraction Fraction of data used for training.
#'
#' @return A fitted model object of class `"gbm"`.
#' @keywords internal
engine_train_gbm <- function(
    formula,
    data,
    sample_weight,
    distribution,
    n.trees,
    interaction.depth,
    shrinkage,
    n.minobsinnode,
    bag.fraction,
    train.fraction
) {
  args <- list(
    formula           = formula,
    data              = data,
    weights           = sample_weight,
    distribution      = distribution,
    n.trees           = n.trees,
    interaction.depth = interaction.depth,
    shrinkage         = shrinkage,
    n.minobsinnode    = n.minobsinnode,
    bag.fraction      = bag.fraction,
    train.fraction    = train.fraction,
    verbose           = FALSE
  )
  do.call(gbm::gbm, args)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Training Engine: Gradient Boosting Machine (GBM)
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' performs light target adaptation (0/1 for bernoulli), and invokes the GBM training engine.
#' Returns standardized output using `initialize_output_train()`.
#'
#' **Standardized Inputs:**
#' - `control$params$train$formula`: A formula specifying the model structure.
#' - `control$params$train$data`: Named list with training data (`original` and/or `normalized`).  
#'   → This list is automatically provided by the workflow, not by the user.
#' - `control$params$train$norm_data`: Logical flag indicating whether to use normalized data.
#' - `control$params$train$params`: Optional user-specified hyperparameters.
#'
#' **Engine-Specific Parameters (`control$params$train$params`):**
#' - `distribution` *(char)*: "gaussian" or "bernoulli". If `NULL`, inferred from target (binary → bernoulli).
#' - `n.trees` *(int)*: Number of trees (default: 1000).
#' - `interaction.depth` *(int)*: Tree depth (default: 3).
#' - `shrinkage` *(num)*: Learning rate (default: 0.05).
#' - `n.minobsinnode` *(int)*: Min obs per terminal node (default: 10).
#' - `bag.fraction` *(num)*: Subsample fraction per tree (default: 0.5).
#' - `train.fraction` *(num)*: Fraction of data used for training (default: 1.0).
#' - `sample_weight` *(numeric vector)*: Observation weights (optional; defaults to equal weights).
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$train <- "train_gbm"
#' control$params$train <- controller_training(
#'   formula = target ~ .,
#'   norm_data = TRUE,
#'   params = list(
#'     distribution = "bernoulli",
#'     n.trees = 1500,
#'     interaction.depth = 3,
#'     shrinkage = 0.05,
#'     bag.fraction = 0.7
#'   )
#' )
#' ```
#' **Template Reference:**
#' See full template in `inst/templates_control/4_c_template_train_gbm.R`
#'
#' **Standardized Output (returned to framework):**
#' - A structured list created by `initialize_output_train()`:
#'   - `model`: Fitted model object.
#'   - `model_type`: Identifier string ("gbm").
#'   - `formula`: Used training formula.
#'   - `hyperparameters`: Merged hyperparameter set.
#'   - `specific_output`: Training duration and optional metadata (e.g., class mapping).
#' 
#' @seealso 
#'   [engine_train_gbm()],  
#'   [default_params_train_gbm()],  
#'   [initialize_output_train()],  
#'   [controller_training()]
#'
#' @param control A standardized control object (see `controller_training()`).
#' @return A standardized output list structured via `initialize_output_train()`.
#' @keywords internal
wrapper_train_gbm <- function(control) {
  train_params <- control$params$train
  
  if (is.null(train_params$formula)) {
    stop("wrapper_train_gbm: Missing required input: formula")
  }
  if (is.null(train_params$data)) {
    stop("wrapper_train_gbm: Missing required input: data")
  }
  
  # Select training data (original vs. normalized)
  train_data <- select_training_data(train_params$norm_data, train_params$data)
  
  # Merge user params with defaults
  hyperparameters <- merge_with_defaults(train_params$params, default_params_train_gbm())
  
  # Prepare weights
  if (is.null(hyperparameters$sample_weight)) {
    hyperparameters$sample_weight <- rep(1, nrow(train_data))
  }
  train_data$sample_weight <- hyperparameters$sample_weight
  
  # Infer distribution if not given
  # Extract response variable name from formula
  response <- all.vars(train_params$formula)[1]
  y <- train_data[[response]]
  
  infer_distribution <- function(y) {
    # If binary (0/1 or 2-level factor/character), choose "bernoulli"; otherwise "gaussian"
    if (is.factor(y)) {
      return(if (nlevels(y) == 2) "bernoulli" else "gaussian")
    }
    if (is.logical(y)) return("bernoulli")
    if (is.numeric(y)) {
      # 0/1 → bernoulli
      uy <- unique(na.omit(y))
      if (length(uy) <= 3 && all(uy %in% c(0,1))) return("bernoulli")
    }
    "gaussian"
  }
  
  if (is.null(hyperparameters$distribution)) {
    hyperparameters$distribution <- infer_distribution(y)
  }
  
  # For bernoulli, ensure target is numeric 0/1 as expected by gbm
  class_mapping <- NULL
  if (identical(hyperparameters$distribution, "bernoulli")) {
    if (is.factor(y)) {
      lev <- levels(y)
      if (length(lev) != 2) {
        stop("wrapper_train_gbm: bernoulli requires a binary target.")
      }
      # Map: first level -> 0, second level -> 1 (documented in specific_output)
      train_data[[response]] <- as.numeric(y == lev[2])
      class_mapping <- list(levels = lev, mapping = setNames(c(0,1), lev))
    } else if (is.logical(y)) {
      # gbm expects numeric 0/1; as.numeric(FALSE)=0, as.numeric(TRUE)=1
      train_data[[response]] <- as.numeric(y)
      class_mapping <- list(
        levels  = c("FALSE", "TRUE"),
        mapping = setNames(c(0, 1), c("FALSE", "TRUE"))  # names must be strings
      )
    } else if (is.numeric(y)) {
      uy <- unique(na.omit(y))
      if (!all(uy %in% c(0,1))) {
        stop("wrapper_train_gbm: For bernoulli, numeric target must be coded as 0/1.")
      }
    }
  }
  
  log_msg("[TRAIN] Starting GBM training...", level = "info", control = control)
  start_time <- Sys.time()
  
  model <- engine_train_gbm(
    formula            = train_params$formula,
    data               = train_data,
    sample_weight      = hyperparameters$sample_weight,
    distribution       = hyperparameters$distribution,
    n.trees            = hyperparameters$n.trees,
    interaction.depth  = hyperparameters$interaction.depth,
    shrinkage          = hyperparameters$shrinkage,
    n.minobsinnode     = hyperparameters$n.minobsinnode,
    bag.fraction       = hyperparameters$bag.fraction,
    train.fraction     = hyperparameters$train.fraction
  )
  
  training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  log_msg(sprintf("[TRAIN] GBM training finished in %.2f seconds.", training_time), level = "info", control = control)
  
  initialize_output_train(
    model = model,
    model_type = "gbm",
    formula = train_params$formula,
    hyperparameters = hyperparameters,
    specific_output = list(
      training_time = training_time,
      class_mapping = class_mapping
    )
  )
}
#--------------------------------------------------------------------




#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Training Engine: GBM
#'
#' Provides default parameters for the GBM training engine.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_training` function**, which include:
#'   - `formula`: A formula specifying the model structure.
#'   - `data`: A data frame containing the training data.
#'   
#' **Additional Parameters:**
#' - `distribution`: Loss function; if `NULL`, inferred from target ("bernoulli" for binary, else "gaussian").
#' - `n.trees`: Number of boosting iterations (default: 1000).
#' - `interaction.depth`: Tree depth (default: 3).
#' - `shrinkage`: Learning rate (default: 0.05).
#' - `n.minobsinnode`: Min obs per terminal node (default: 10).
#' - `bag.fraction`: Subsampling per tree (default: 0.5).
#' - `train.fraction`: Fraction of rows used for training (default: 1.0).
#' - `sample_weight`: Vector of observation weights (optional).
#'
#' @seealso [wrapper_train_gbm()]
#'
#' @return A list of default hyperparameters for the GBM training engine.
#' @keywords internal
default_params_train_gbm <- function() {
  list(
    distribution      = NULL,  # auto-infer if not provided
    n.trees           = 1000,
    interaction.depth = 3,
    shrinkage         = 0.05,
    n.minobsinnode    = 10,
    bag.fraction      = 0.5,
    train.fraction    = 1.0,
    sample_weight     = NULL
  )
}
#--------------------------------------------------------------------