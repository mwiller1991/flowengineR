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
  
  # Default values
  split_params$split_ratio <- split_params$split_ratio %||% 0.7  # Default to 70% training data if not provided
  
  message(sprintf("[INFO] Performing random split with training ratio %.2f and seed %d", split_params$split_ratio, split_params$seed))
  
  # Call the random split engine
  split <- engine_split_random(
    data = control$data$full,
    split_ratio = split_params$split_ratio,
    seed = split_params$seed
  )
  
  # Update control with the split data
  control$data$train <- split$train
  control$data$test <- split$test
  
  # Call the single workflow for the random split
  workflow_results <- list(run_workflow_single(control))
  
  # Return standardized output
  return(list(
    splits = list(random_split = split),
    workflow_results = workflow_results,
    aggregated_results = aggregate_results(workflow_results)
  ))
}
#--------------------------------------------------------------------