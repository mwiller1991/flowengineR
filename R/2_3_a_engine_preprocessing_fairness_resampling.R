#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Fairness Pre-Processing Engine: Resampling
#'
#' Applies resampling (oversampling or undersampling) to balance class distribution in the target variable.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `data`: The input data frame to be resampled.
#' - `target_var`: Character string specifying the target variable.
#' - `params`: List of engine-specific parameters, e.g., `method = "oversampling"` or `"undersampling"`.
#'
#' **Output (returned to wrapper):**
#' - A list containing:
#'   - `preprocessed_data`: The resampled data frame.
#'   - `specific_output`: Metadata including original and new class distributions.
#'   
#' @seealso [wrapper_preprocessing_fairness_resampling()]
#'
#' @param data The input data frame.
#' @param target_var The name of the target variable.
#' @param params A list of parameters for resampling.
#'
#' @return A list containing the resampled data and optional statistics.
#' @keywords internal
engine_preprocessing_fairness_resampling <- function(data, target_var, params) {
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
#' Wrapper for Fairness Pre-Processing Engine: Resampling
#'
#' Validates and prepares standardized inputs, merges default and user-defined parameters,
#' and invokes the resampling engine. This wrapper ensures compatibility with the internal structure
#' of the fairnessToolbox and produces standardized output via `initialize_output_pre()`.
#'
#' **Standardized Inputs:**
#' - `control$params$preprocessing$data`: Input data to be resampled, taken from `control$data$train`.
#' - `control$params$preprocessing$target_var`: Name of the target variable.  
#'   → Auto-filled from `control$vars$target_var` via `autofill_controllers_from_vars()`.
#' - `control$params$preprocessing$protected_attributes`: Not used in this engine but passed through for consistency.
#' - `control$params$preprocessing$params`: Optional engine-specific parameters.
#'
#' **Engine-Specific Parameters (`control$params$preprocessing$params`):**
#' - `method` *(character)*: Resampling strategy to use. Supported:
#'   - `"oversampling"`: Duplicates minority class samples.
#'   - `"undersampling"`: Reduces majority class samples.
#' - `target_ratio` *(numeric, default = 1)*: Intended ratio between classes (currently unused but reserved).
#'
#' **Workflow Integration:**
#' - `target_var` and `protected_attributes` are automatically resolved based on `control$vars`.
#' - These values must be respected by engines but should **not be set manually**.
#'
#' **Example Control Snippet:**
#' ```r
#' control$preprocessing <- "preprocessing_fairness_resampling"
#' control$params$preprocessing <- controller_preprocessing(
#'   params = list(method = "undersampling")
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/4_a_template_preprocessing_fairness_resampling.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_pre()`:
#' - `preprocessed_data`: The resampled dataset.
#' - `method`: `"resampling"`.
#' - `params`: Final merged parameter list.
#' - `specific_output`: Original and new class distributions (as named lists).
#'
#' @seealso 
#'   [engine_preprocessing_fairness_resampling()],  
#'   [default_params_preprocessing_fairness_resampling()],  
#'   [initialize_output_pre()],  
#'   [controller_preprocessing()],  
#'   Template: `inst/templates_control/4_a_template_preprocessing_fairness_resampling.R`
#'
#' @param control A standardized control object (see `controller_preprocessing()`). Must include `control$vars`.
#' @return A standardized fairness pre-processing output.
#' @keywords internal
wrapper_preprocessing_fairness_resampling <- function(control) {
  pre_params <- control$params$preprocessing  # Access pre-processing parameters
  
  if (is.null(pre_params$data)) {
    stop("Wrapper: Missing required input: data")
  }
  if (is.null(pre_params$target_var)) {
    stop("Wrapper: Missing required input: target variable")
  }
  
  # Merge optional parameters with defaults
  params <- merge_with_defaults(pre_params$params, default_params_preprocessing_fairness_resampling())
  
  log_msg(sprintf("[PRE] Starting resampling (%s)...", params$method),
          level = "info", control = control)
  
  # Call the specific resampling engine
  engine_output <- engine_preprocessing_fairness_resampling(
    data = pre_params$data,
    target_var = pre_params$target_var,
    params = params
  )
  
  # Log class distribution
  old <- engine_output$specific_output$original_counts
  new <- engine_output$specific_output$new_counts
  log_msg(sprintf("[PRE] Original: %s | New: %s",
                  paste(names(old), unlist(old), sep = "=", collapse = ", "),
                  paste(names(new), unlist(new), sep = "=", collapse = ", ")),
          level = "info", control = control)
  
  # Use standardized output
  initialize_output_preprocessing(
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
#' @seealso [wrapper_preprocessing_fairness_resampling()]
#'
#' @return A list of default parameters for the resampling pre-processing engine.
#' @keywords internal
default_params_preprocessing_fairness_resampling <- function() {
  list(
    method = "oversampling"
  )
}
#--------------------------------------------------------------------