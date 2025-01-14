#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Pre-Processing Engine: Resampling
#'
#' Performs resampling (oversampling or undersampling) to balance the target variable distribution.
#'
#' **Inputs:**
#' - `data`: The input data frame to be processed.
#' - `target_var`: The name of the target variable for resampling.
#' - `params`: A list of parameters including the resampling method ("oversampling" or "undersampling").
#'
#' **Outputs (passed to wrapper):**
#' - `transformed_data`: The resampled data frame.
#' - `specific_output`: A list containing:
#'   - `original_counts`: Original class distribution before resampling.
#'   - `new_counts`: Class distribution after resampling.
#'
#' @param data The input data frame.
#' @param target_var The name of the target variable.
#' @param params A list of parameters for resampling.
#' @return A list containing the resampled data and optional statistics.
#' @export
engine_fairness_pre_resampling <- function(data, target_var, params) {
  # Perform resampling
  class_counts <- table(data[[target_var]])
  
  if (params$method == "oversampling") {
    # Oversample minority class
    minority_class <- names(which.min(class_counts))
    oversampled <- data[data[[target_var]] == minority_class, ]
    additional_samples <- oversampled[sample(1:nrow(oversampled),
                                             size = (max(class_counts) - min(class_counts)),
                                             replace = TRUE), ]
    preprocessed_data <- rbind(data, additional_samples)
  } else if (params$method == "undersampling") {
    # Undersample majority class
    majority_class <- names(which.max(class_counts))
    undersampled <- data[data[[target_var]] == majority_class, ]
    sampled_majority <- undersampled[sample(1:nrow(undersampled),
                                            size = min(class_counts)), ]
    preprocessed_data <- rbind(data[data[[target_var]] == names(which.min(class_counts)), ], sampled_majority)
  } else {
    stop("Invalid resampling method.")
  }
  
  # Shuffle the data
  preprocessed_data <- preprocessed_data[sample(1:nrow(preprocessed_data)), ]
  
  # Collect specific outputs (statistics)
  specific_output <- list(
    original_counts = as.list(class_counts),
    new_counts = as.list(table(preprocessed_data[[target_var]]))
  )
  
  return(list(
    preprocessed_data = preprocessed_data,
    specific_output = specific_output
  ))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Pre-Processing Resampling
#'
#' @param control A list containing the data, target variable, and parameters.
#' @return A standardized output list containing the resampled data and metadata.
#' @export
wrapper_fairness_pre_resampling <- function(control) {
  pre_params <- control$params$fairness_pre  # Access pre-processing parameters
  
  if (is.null(pre_params$data)) {
    stop("Wrapper: Missing required input: data")
  }
  if (is.null(pre_params$target_var)) {
    stop("Wrapper: Missing required input: target variable")
  }
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(pre_params$params, default_params_pre_resampling())
  
  # Call the specific resampling engine
  engine_output <- engine_pre_resampling(
    data = pre_params$data,
    target_var = pre_params$target_var,
    params = params
  )
  
  # Use standardized output
  initialize_output_pre(
    preprocessed_data = engine_output$preprocessed_data,
    method = "resampling",
    params = params,
    specific_output = engine_output$specific_output
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Pre-Processing Engines: Resampling
#'
#' Provides default parameters for pre-processing engines. These parameters are specific to resampling and define optional values required for execution.
#'
#' **Purpose:**
#' - Defines engine-specific parameters that are optional but can be adjusted for specific use cases.
#' - These parameters are **not covered by the base fields in the `controller_pre_processing` function**, which include:
#'   - `data`: The input data frame.
#'   - `target_var`: The name of the target variable.
#' - **Additional Parameters:**
#'   - `method`: The resampling method to use (default: "oversampling").
#'   - `target_ratio`: The target ratio for balancing classes (default: `1`).
#' - Ensures default parameters are used when none are provided in the `control` object.
#'
#' @return A list of default parameters for the resampling pre-processing engine.
#' @export
default_params_fairness_pre_resampling <- function() {
  list(
    method = "oversampling",
    target_ratio = 1
  )
}
#--------------------------------------------------------------------