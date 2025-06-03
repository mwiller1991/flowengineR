#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Split Engine: Cross-Validation (CV)
#'
#' Creates stratified k-fold cross-validation indices using the specified target variable and number of folds.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `data`: A data frame to be split.
#' - `target_var`: Character string, target variable for stratified splitting.
#' - `cv_folds`: Number of folds for cross-validation.
#' - `seed`: Integer seed for reproducibility.
#'
#' **Output (returned to wrapper):**
#' - A list of train/test split pairs.
#' 
#' @seealso [wrapper_split_cv()]
#'
#' @param data A data frame to be split into folds.
#' @param target_var The name of the target variable for stratified sampling.
#' @param cv_folds The number of folds for cross-validation.
#' @param seed A random seed for reproducibility.
#'
#' @return A list of train/test split indices per fold.
#' @keywords internal
engine_split_cv <- function(data, target_var, cv_folds, seed) {
  # Set random seed for reproducibility
  set.seed(seed)
  
  # Create stratified folds based on target variable
  folds <- caret::createFolds(data[[target_var]], k = cv_folds, list = TRUE)
  names(folds) <- paste0("fold", seq_along(folds))
  
  # Construct split list with train/test data for each fold
  split_list <- lapply(folds, function(test_idx) {
    list(
      train = data[-test_idx, ],
      test = data[test_idx, ]
    )
  })
  
  # Return list of splits
  return(split_list)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Split Engine: Cross-Validation (CV)
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' and invokes the CV split engine. Returns standardized output using `initialize_output_split()`.
#'
#' **Standardized Inputs:**
#' - `control$data$full`: Full dataset to be split (required).
#' - `control$params$split$seed`: Integer seed for reproducibility.
#' - `control$params$split$target_var`: Target variable for stratified splitting.
#' - `control$params$split$params`: Optional engine-specific parameters.
#'
#' **Engine-Specific Parameters (`control$params$split$params`):**
#' This engine supports the following parameter:
#' - `cv_folds` *(integer, default = 5)*: Number of folds for cross-validation. Must be >1.
#'
#' **Notes:**
#' - Stratification is applied based on the `target_var`.
#' - If `cv_folds = 1`, validation fails because training would be empty.
#' 
#' **Workflow Integration:**
#' - `target_var` is **automatically resolved** from `control$data$vars$target_var` 
#'   if not provided explicitly in the controller.
#' - This allows users to define `target_var` only once in `controller_vars()`.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$split <- "split_cv"
#' control$params$split <- controller_split(
#'   seed = 42,
#'   target_var = "default",
#'   params = list(cv_folds = 5)
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/1_a_template_control_split_cv.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_split()` with:
#' - `split_type`: "cv"
#' - `splits`: List of named folds, each with `train` and `test` data.frames.
#' - `seed`: Used seed.
#' - `params`: Merged parameter list (user + default).
#' - `specific_output`: Fold count and stratification info.
#'
#' @seealso 
#'   [engine_split_cv()],  
#'   [default_params_split_cv()],  
#'   [initialize_output_split()],  
#'   [controller_split()],  
#'   Template: `inst/templates_control/1_a_template_control_split_cv.R`  
#'   Helper: [show_template()]
#'
#' @param control A standardized control object (see `controller_split()`).
#'
#' @return A standardized splitter output object with k-fold train/test splits.
#' @keywords internal
wrapper_split_cv <- function(control) {
  split_params <- control$params$split
  
  if (is.null(control$data$full)) {
    stop("wrapper_split_cv: Missing required input: full dataset")
  }
  if (is.null(split_params$target_var)) {
    stop("wrapper_split_cv: target_var must be provided via controller_split.")
  }
  
  # Merge default parameters
  params <- merge_with_defaults(split_params$params, default_params_split_cv())
  
  if (params$cv_folds == 1) {
    stop("wrapper_split_cv: CV fold count is 1 → this will result in empty training data. Consider using a different splitter (e.g., stratified_random).")
  }
  
  log_msg(sprintf("[SPLIT] Performing %d-fold cross-validation with seed %d.", params$cv_folds, split_params$seed), level = "info", control = control)
  
  # Call CV splitter engine
  splits <- engine_split_cv(
    data = control$data$full,
    target_var = split_params$target_var,
    cv_folds = params$cv_folds,
    seed = split_params$seed
  )
  
  # Standardized output
  initialize_output_split(
    split_type = "cv",
    splits = splits,
    seed = split_params$seed,
    params = params,
    specific_output = list(
      folds = length(splits),
      stratified_on = split_params$target_var
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Splitter Engines: CV
#'
#' Provides default parameters for splitter engines. These parameters are specific to each engine and define optional values required for execution.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_split` function**, which include:
#'   - `seed`: Random seed to ensure reproducibility (default: 123).
#'   - `target_var`: Target variable used for stratification.
#' - **Additional Parameters:**
#'   - `cv_folds`: Number of folds to create (default: 5).
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @seealso [wrapper_split_cv()]
#'
#' @return A list of default parameters for the splitter engine.
#' @keywords internal
default_params_split_cv <- function() {
  list(
    cv_folds = 5  # Default to 5-fold CV
  )
}
#--------------------------------------------------------------------