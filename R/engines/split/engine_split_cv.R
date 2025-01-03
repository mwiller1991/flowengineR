#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Cross-Validation Split Engine
#'
#' @param data A data frame to be split into folds.
#' @param target_var The name of the target variable for stratified sampling.
#' @param cv_folds The number of folds for cross-validation.
#' @param seed A random seed for reproducibility.
#' @return A list containing indices for each fold.
#' @export
engine_split_cv <- function(data, target_var, cv_folds, seed) {
  set.seed(seed)
  folds <- caret::createFolds(data[[target_var]], k = cv_folds, list = TRUE)
  return(folds)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Cross-Validation Split Engine
#'
#' @param control A list containing control parameters and dataset.
#' @return A standardized list containing splits, workflow results, and aggregated results.
#' @export
wrapper_split_cv <- function(control) {
  split_params <- control$params$split
  if (is.null(control$data$full)) {
    stop("wrapper_split_cv: Missing required input: full dataset")
  }
  if (is.null(control$vars$target_var)) {
    stop("wrapper_split_cv: Missing required input: target variable")
  }
  
  # Default values
  split_params$cv_folds <- split_params$cv_folds %||% 5  # Default to 5 folds if not provided
  
  message(sprintf("[INFO] Performing %d-fold cross-validation with seed %d", split_params$cv_folds, split_params$seed))
  
  # Call the engine
  folds <- engine_split_cv(
    data = control$data$full,
    target_var = control$vars$target_var,
    cv_folds = split_params$cv_folds,
    seed = split_params$seed
  )
  
  # Run the workflow for each fold
  workflow_results <- lapply(folds, function(indices) {
    control$data$train <- control$data$full[-indices, ]
    control$data$test <- control$data$full[indices, ]
    
    # Call the single workflow
    run_workflow_single(control)
  })
  
  # Aggregate results for CV
  aggregated_results <- aggregate_results(workflow_results)
  
  # Return standardized output
  return(list(
    splits = folds,
    workflow_results = workflow_results,
    aggregated_results = aggregated_results
  ))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
default_params_split_cv <- function() {
  list()  # MSE evaluation does not require specific parameters
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### helper for aggregation ###
#--------------------------------------------------------------------
#' Aggregate Results from Cross-Validation
#'
#' @param results A list of results from each fold.
#' @return A list containing aggregated evaluation metrics.
#' @export
aggregate_results <- function(results) {
  aggregated_evaluation <- lapply(names(results[[1]]$evaluation), function(metric) {
    sapply(results, function(res) res$evaluation[[metric]]) %>% mean()
  })
  names(aggregated_evaluation) <- names(results[[1]]$evaluation)
  list(
    model = results[[1]]$model, # Example: the model from the first fold
    evaluation = aggregated_evaluation
  )
}
#--------------------------------------------------------------------