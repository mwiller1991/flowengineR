#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Split Engine: Random Split
#'
#' Randomly splits the dataset into training and test sets using a specified ratio and seed.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `data`: A data frame to be split.
#' - `split_ratio`: Proportion of data to use for training (between 0 and 1).
#' - `seed`: Integer seed for reproducibility.
#'
#' **Output (returned to wrapper):**
#' - A list with elements `train` and `test`, each containing a subset of the data.
#' 
#' @seealso [wrapper_split_random()]
#'
#' @param data A data frame to be split.
#' @param split_ratio The ratio of data to use for training.
#' @param seed A random seed for reproducibility.
#'
#' @return A list containing train and test data splits.
#' @keywords internal
engine_split_random <- function(data, split_ratio, seed) {
  set.seed(seed)
  train_indices <- sample(1:nrow(data), size = split_ratio * nrow(data))
  list(
    train = data[train_indices, ],
    test = data[-train_indices, ]
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Split Engine: Random Split
#'
#' Validates and prepares standardized inputs, merges default and user-defined hyperparameters,
#' and invokes the random split engine. Returns standardized output using `initialize_output_split()`.
#'
#' **Standardized Inputs:**
#' - `control$data$full`: Full dataset to be split (required).
#' - `control$params$split$seed`: Integer seed for reproducibility.
#' - `control$params$split$target_var`: Target variable (not used in this engine, but required structurally).
#' - `control$params$split$params`: Optional engine-specific parameters.
#'
#' **Engine-Specific Parameters (`control$params$split$params`):**
#' This engine supports the following parameter:
#' - `split_ratio` *(numeric, default = 0.7)*: Proportion of the dataset to use for training. Must be in (0, 1).
#'
#' **Notes:**
#' - The target variable is ignored by this engine but must still be defined for compatibility.
#' - This engine performs no stratification. For stratified splitting, consider using `"split_random_stratified"`.
#'
#' **Example Control Snippet:**
#' ```
#' control$split_method <- "split_random"
#' control$params$split <- controller_split(
#'   seed = 42,
#'   target_var = "default",  # Required by framework, ignored here
#'   params = list(split_ratio = 0.6)
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates/1_c_template_control_split_random.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_split()` with:
#' - `split_type`: "random"
#' - `splits`: Named list with one element `random` containing `train` and `test` data.frames.
#' - `seed`: Used seed.
#' - `params`: Merged parameter list (user + default).
#' - `specific_output`: `NULL` (no additional metadata for this engine).
#' 
#' @seealso 
#'   [engine_split_random()],  
#'   [default_params_split_random()],  
#'   [initialize_output_split()],  
#'   [controller_split()],  
#'   Template: `inst/templates/1_c_template_control_split_random.R`  
#'   Helper: [show_template()]
#'
#' @param control A standardized control object (see `controller_split()`).
#'
#' @return A standardized splitter output object with train/test split.
#' @keywords internal
wrapper_split_random <- function(control) {
  split_params <- control$params$split
  
  if (is.null(control$data$full)) {
    stop("wrapper_split_random: Missing required input: full dataset")
  }
  
  # Merge default parameters
  params <- merge_with_defaults(split_params$params, default_params_split_random())
  
  message(sprintf("[INFO] Performing random split with training ratio %.2f and seed %d", params$split_ratio, split_params$seed))
  
  # Call the random split engine
  split <- engine_split_random(
    data = control$data$full,
    split_ratio = params$split_ratio,
    seed = split_params$seed
  )
  
  # Standardized output
  initialize_output_split(
    split_type = "random",
    splits = list(random = split),
    seed = split_params$seed,
    params = params,
    specific_output = NULL  # No specific output for general residual method
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Splitter Engines: Random
#'
#' Provides default parameters for splitter engines. These parameters are specific to each engine and define optional values required for execution.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_split` function**, which include:
#'   - `seed`: Random seed to ensure reproducibility (default: 123).
#'   - `data`: A data frame containing the input dataset.
#' - **Additional Parameters:**
#'   - `split_ratio`: Proportion of data to be used for training (default: 0.7).
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @seealso [wrapper_split_random()]
#'
#' @return A list of default parameters for the splitter engine.
#' @keywords internal
default_params_split_random <- function() {
  list(
    split_ratio = 0.7   # Default 70% training
  )
}
#--------------------------------------------------------------------