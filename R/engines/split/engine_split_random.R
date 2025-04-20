#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Random Split Engine
#'
#' @param data A data frame to be split.
#' @param split_ratio The ratio of data to use for training.
#' @param seed A random seed for reproducibility.
#' @return A list containing train and test data splits.
#' @export
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
#' Wrapper for Random Split Engine
#'
#' @param control A list containing control parameters and dataset.
#' @return A standardized list containing splits, fold results, and aggregated results.
#' @export
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
#' @return A list of default parameters for the splitter engine.
#' @export
default_params_split_random <- function() {
  list(
    split_ratio = 0.7   # Default 70% training
  )
}
#--------------------------------------------------------------------