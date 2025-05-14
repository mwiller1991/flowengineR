#--------------------------------------------------------------------
# Helper Function to Merge User-Provided and Default Hyperparameters
#--------------------------------------------------------------------
#' Helper Function to Merge User-Provided and Default Hyperparameters
#'
#' @param user_hyperparameters A list of hyperparameters provided by the user.
#' @param default_hyperparameters A list of default hyperparameters for the model.
#'
#' @return A list of hyperparameters where missing values are filled with defaults.
#' @export
merge_with_defaults <- function(user_hyperparameters, default_hyperparameters) {
  if (is.null(user_hyperparameters)) {
    return(default_hyperparameters)
  }
  # Combine defaults and user-provided parameters
  modifyList(default_hyperparameters, user_hyperparameters)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Normalize Data
#--------------------------------------------------------------------
#' Compute Min-Max Normalization Parameters
#'
#' @param data A data frame with training data.
#' @param feature_names A character vector with names of features to normalize.
#'
#' @return A named list with min and max per feature.
compute_minmax_params <- function(data, feature_names) {
  params <- list()
  for (feature in feature_names) {
    if (is.numeric(data[[feature]])) {
      params[[feature]] <- list(
        min = min(data[[feature]], na.rm = TRUE),
        max = max(data[[feature]], na.rm = TRUE)
      )
    }
  }
  return(params)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Normalize Data
#--------------------------------------------------------------------
#' Apply Min-Max Normalization using Precomputed Parameters
#'
#' @param data A data frame to normalize.
#' @param params A list of min/max values per feature.
#'
#' @return A normalized data frame.
apply_minmax_params <- function(data, params) {
  for (feature in names(params)) {
    if (is.numeric(data[[feature]])) {
      min_val <- params[[feature]]$min
      max_val <- params[[feature]]$max
      if (max_val - min_val != 0) {
        data[[feature]] <- (data[[feature]] - min_val) / (max_val - min_val)
      } else {
        data[[feature]] <- 0  # oder NA, wenn du lieber Fehler werfen willst
      }
    }
  }
  return(data)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Select Training Data
#--------------------------------------------------------------------
#' Helper Function to Select Training Data
#'
#' Selects the appropriate dataset (normalized or original) for training
#' based on the `norm_data` flag.
#'
#' @param norm_data A logical value indicating whether normalized data should be used.
#'   - `TRUE`: Use the normalized dataset.
#'   - `FALSE`: Use the original dataset.
#' @param data A list containing two datasets:
#'   - `data$normalized`: The normalized dataset.
#'   - `data$original`: The original dataset.
#'
#' @return A data frame containing the selected dataset (normalized or original).
#' @export
select_training_data <- function(norm_data, data) {
  if (isTRUE(norm_data)) {
    # Use normalized data if specified
    return(data$normalized)
  } else {
    # Use original data by default
    return(data$original)
  }
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# Helper Function to Denormalize Predictions
#--------------------------------------------------------------------
#' Helper Function to Denormalize Predictions
#'
#' Takes predictions made on normalized data and transforms them back to the original scale
#' using the original dataset's min and max values.
#'
#' @param predictions A numeric vector of predictions made on normalized data.
#' @param original_data A data frame containing the original, non-normalized dataset.
#' @param feature_name The name of the feature/column for which the predictions were made.
#'
#' @return A numeric vector of predictions transformed back to the original scale.
#' @export
denormalize_predictions <- function(predictions, feature_name, norm_params) {
  # Extract the min and max values from the original data
  min_original <- norm_params[[feature_name]]$min
  max_original <- norm_params[[feature_name]]$max
  
  # Transform predictions back to the original scale
  predictions_original_scale <- predictions * (max_original - min_original) + min_original
  
  return(predictions_original_scale)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### helper for aggregation ###
#--------------------------------------------------------------------
#' Helper Function: Aggregate Evaluation Metrics across Splits
#'
#' Aggregates both flat and nested evaluation metrics across multiple splits.
#'
#' @param workflow_results A list of results from `run_workflow_single()` per split.
#' @return A named list of aggregated metrics.
#' @export
#--------------------------------------------------------------------
aggregate_results <- function(workflow_results) {
  
  collected_metrics <- list()
  
  for (i in seq_along(workflow_results)) {
    result <- workflow_results[[i]]
    
    if (is.null(result$output_eval)) next
    
    for (eval_method in names(result$output_eval)) {
      eval_metrics <- result$output_eval[[eval_method]]$metrics
      for (metric_name in names(eval_metrics)) {
        collected_metrics[[metric_name]] <- append(collected_metrics[[metric_name]], list(eval_metrics[[metric_name]]))
      }
    }
  }
  
  aggregated <- list()
  
  for (metric_name in names(collected_metrics)) {
    values <- collected_metrics[[metric_name]]
    
    # Fall: Nested Metriken (wie summary_stats)
    if (is.list(values[[1]]) && !is.null(names(values[[1]]))) {
      df <- do.call(rbind, lapply(values, function(x) as.data.frame(t(unlist(x)))))
      nested_agg <- lapply(names(df), function(submetric) {
        subvals <- df[[submetric]]
        list(
          mean = mean(subvals, na.rm = TRUE),
          sd = sd(subvals, na.rm = TRUE)
        )
      })
      names(nested_agg) <- names(df)
      aggregated[[metric_name]] <- nested_agg
      
    } else {
      # Fall: einfache numerische Metrik (z. B. mse, stat_parity)
      values <- unlist(values)
      aggregated[[metric_name]] <- list(
        mean = mean(values, na.rm = TRUE),
        sd = sd(values, na.rm = TRUE),
        min = min(values, na.rm = TRUE),
        max = max(values, na.rm = TRUE)
      )
    }
  }
  
  return(aggregated)
}
#--------------------------------------------------------------------


#--------------------------------------------------------------------
### helper for aggregation ###
#--------------------------------------------------------------------
#' Internal Helper: Validate Engine Structure
#'
#' Validates structural consistency of an engine wrapper function.
#'
#' @param wrapper_function The wrapper function.
#' @param engine_name The short engine name, e.g., "train_glm".
#' @param expected_args A character vector of expected formal argument names.
#' @param expected_output_initializer The name of the expected initialize_output_* function.
#'
#' @return TRUE if structure is valid, error otherwise.
#' @export
#' #--------------------------------------------------------------------
validate_engine_structure <- function(wrapper_function, engine_name, expected_args, expected_output_initializer) {
  wrapper_function_name <- paste0("wrapper_", engine_name)
  engine_function_name <- paste0("engine_", engine_name)
  default_params_function_name <- paste0("default_params_", engine_name)
  
  # Check existence of required functions
  if (!exists(engine_function_name, mode = "function", envir = .GlobalEnv)) {
    stop(paste("[WARNING] Engine function", engine_function_name, "not found in global environment."))
  }
  if (!exists(default_params_function_name, mode = "function", envir = .GlobalEnv)) {
    stop(paste("[WARNING] Default params function", default_params_function_name, "not found in global environment."))
  }
  if (!is.function(wrapper_function)) stop("[WARNING] Wrapper is not a function.")
  if (!is.function(get(engine_function_name))) stop("[WARNING] Engine is not a function.")
  if (!is.function(get(default_params_function_name))) stop("[WARNING] Default params is not a function.")
  
  # Check wrapper function arguments
  actual_args <- names(formals(wrapper_function))
  if (!identical(actual_args, expected_args)) {
    warning(sprintf(
      "[INFO] Wrapper arguments do not match expected signature. Expected: %s, Found: %s",
      paste(expected_args, collapse = ", "),
      paste(actual_args, collapse = ", ")
    ))
  }
  
  # Check if output initializer is called
  wrapper_body <- deparse(body(wrapper_function))
  if (!any(grepl(expected_output_initializer, wrapper_body))) {
    warning(sprintf("[INFO] Wrapper does not call %s. Please ensure standardized output.", expected_output_initializer))
  }
  
  return(TRUE)
}
#--------------------------------------------------------------------