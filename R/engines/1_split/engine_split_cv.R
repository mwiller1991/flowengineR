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
#' @param data A data frame to be split into folds.
#' @param target_var The name of the target variable for stratified sampling.
#' @param cv_folds The number of folds for cross-validation.
#' @param seed A random seed for reproducibility.
#'
#' @return A list of train/test split indices per fold.
#' @export
engine_split_cv <- function(data, target_var, cv_folds, seed) {
  set.seed(seed)
  folds <- caret::createFolds(data[[target_var]], k = cv_folds, list = TRUE)
  names(folds) <- paste0("fold", seq_along(folds))
  
  split_list <- lapply(folds, function(test_idx) {
    list(
      train = data[-test_idx, ],
      test = data[test_idx, ]
    )
  })
  
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
#' - `control$params$split$seed`: Seed for reproducibility.
#' - `control$params$split$target_var`: Target variable for stratified splitting.
#' - `control$params$split$params`: Optional user-specified parameters (e.g., `cv_folds`).
#' - `control$data$full`: Full dataset to be split.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_split()`:
#'   - `split_type`: "cv".
#'   - `splits`: List of split definitions.
#'   - `seed`: Used seed.
#'   - `params`: Merged parameter list.
#'   - `specific_output`: Metadata such as number of folds and stratification variable.
#'
#' @param control A standardized control object (see `controller_split()`).
#' @return A standardized splitter output object with multiple splits.
#' @export
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
  
  message(sprintf("[INFO] Performing %d-fold cross-validation with seed %d", params$cv_folds, split_params$seed))
  
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
#' @return A list of default parameters for the splitter engine.
#' @export
default_params_split_cv <- function() {
  list(
    cv_folds = 5  # Default to 5-fold CV
  )
}
#--------------------------------------------------------------------