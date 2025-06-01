#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Split Engine: Stratified Random Split
#'
#' Performs a stratified split of the dataset into training and test sets using a specified ratio and seed.
#' Stratification is based on a target variable to ensure balanced class representation.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `data`: A data frame to be split.
#' - `target_var`: Target variable used for stratification.
#' - `split_ratio`: Proportion of data to use for training (between 0 and 1).
#' - `seed`: Integer seed for reproducibility.
#'
#' **Output (returned to wrapper):**
#' - A list with elements `train` and `test`, each containing a subset of the data.
#'
#' @seealso [wrapper_split_random_stratified()]
#'
#' @param data A data frame to be split.
#' @param target_var A character string specifying the column for stratification.
#' @param split_ratio The ratio of data to use for training.
#' @param seed A random seed for reproducibility.
#'
#' @return A list containing train and test data splits.
#' @keywords internal
engine_split_random_stratified <- function(data, target_var, split_ratio, seed) {
  set.seed(seed)
  idx <- caret::createDataPartition(data[[target_var]], p = split_ratio, list = FALSE)
  list(
    train = data[idx, ],
    test  = data[-idx, ]
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Split Engine: Stratified Random Split
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' and invokes the stratified random split engine. Returns standardized output using `initialize_output_split()`.
#'
#' **Standardized Inputs:**
#' - `control$data$full`: Full dataset to be split (required).
#' - `control$params$split$seed`: Integer seed for reproducibility.
#' - `control$params$split$target_var`: Target variable used for stratification.
#' - `control$params$split$params`: Optional engine-specific parameters.
#'
#' **Engine-Specific Parameters (`control$params$split$params`):**
#' This engine supports the following parameter:
#' - `split_ratio` *(numeric, default = 0.7)*: Proportion of the dataset to use for training. Must be in (0, 1).
#'
#' **Notes:**
#' - The stratification is performed using `caret::createDataPartition()` and ensures balanced class representation in train/test sets.
#' - If the target variable has rare categories, consider whether stratification is meaningful.
#'
#' **Example Control Snippet:**
#' ```
#' control$split_method <- "split_random_stratified"
#' control$params$split <- controller_split(
#'   seed = 123,
#'   target_var = "default",
#'   params = list(split_ratio = 0.75)
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/1_b_template_control_split_random_stratified.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_split()` with:
#' - `split_type`: "random_stratified"
#' - `splits`: Named list with one element `random_stratified` containing `train` and `test` data.frames.
#' - `seed`: Used seed.
#' - `params`: Merged parameter list (user + default).
#' - `specific_output`: `NULL` (no additional metadata for this engine).
#'
#' @seealso 
#'   [engine_split_random_stratified()],  
#'   [default_params_split_random_stratified()],  
#'   [initialize_output_split()],  
#'   [controller_split()],  
#'   Template: `inst/templates_control/1_b_template_control_split_random_stratified.R`  
#'   Helper: [show_template()]
#'
#' @param control A standardized control object (see `controller_split()`).
#'
#' @return A standardized splitter output object with stratified train/test split.
#' @keywords internal
wrapper_split_random_stratified <- function(control) {
  split_params <- control$params$split
  
  if (is.null(control$data$full)) {
    stop("wrapper_split_random_stratified: Missing required input: full dataset")
  }
  if (is.null(split_params$target_var)) {
    stop("wrapper_split_random_stratified: Missing required input: target_var")
  }
  
  # Merge default parameters
  params <- merge_with_defaults(split_params$params, default_params_split_random_stratified())
  
  message(sprintf("[INFO] Performing stratified random split with training ratio %.2f and seed %d", params$split_ratio, split_params$seed))
  
  # Call the stratified random split engine
  split <- engine_split_random_stratified(
    data = control$data$full,
    target_var = split_params$target_var,
    split_ratio = params$split_ratio,
    seed = split_params$seed
  )
  
  # Standardized output
  initialize_output_split(
    split_type = "random_stratified",
    splits = list(random_stratified = split),
    seed = split_params$seed,
    params = params,
    specific_output = NULL
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Splitter Engine: Stratified Random Split
#'
#' Provides default parameters for the `split_random_stratified` engine.
#'
#' **Purpose:**
#' - Defines optional parameters for stratified random splits.
#'
#' **Default Parameters:**
#' - `split_ratio`: Proportion of data to be used for training (default: 0.7).
#'
#' @seealso [wrapper_split_random_stratified()]
#'
#' @return A list of default parameters for the stratified random split engine.
#' @keywords internal
default_params_split_random_stratified <- function() {
  list(
    split_ratio = 0.7  # Default 70% training
  )
}
#--------------------------------------------------------------------