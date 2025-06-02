#--------------------------------------------------------------------
### Helper: Internal Logging Function with Colors (Extended with 'error') ###
#--------------------------------------------------------------------
#' Helper: Internal Logging Function with Colors
#'
#' A centralized logging function for the flowengineR-framework.
#' Supports log level filtering and optional ANSI-colored console output
#' for better visibility during execution.
#'
#' **Log Levels:**
#' - `"none"`: no output.
#' - `"debug"`: detailed diagnostics (grey).
#' - `"info"`: standard process information (blue).
#' - `"warn"`: warnings and recoverable issues (yellow).
#' - `"error"`: critical errors (red, optionally triggers stop()).
#'
#' **Usage Example:**
#' ```r
#' log_msg("[INFO] Workflow started", level = "info", control = control)
#' log_msg("[ERROR] Missing predictions", level = "error", control = control, abort = TRUE)
#' ```
#'
#' @param msg A character string. The message to display.
#' @param level A character string. One of `"none"`, `"debug"`, `"info"`, `"warn"`, `"error"`.
#' @param control The control object containing `settings$log` and `settings$log_level`.
#' @param abort Logical. If `TRUE` and level is `"error"`, the function will stop execution.
#'
#' @return Invisibly returns `NULL`. Used for side-effect printing only.
#' @keywords internal
log_msg <- function(msg, level = "info", control = NULL, abort = FALSE) {
  if (is.null(control) || !isTRUE(control$settings$log)) return(invisible(NULL))
  
  levels <- c("none" = 0, "debug" = 1, "info" = 2, "warn" = 3, "error" = 4)
  user_level <- control$settings$log_level %||% "info"
  if (!(user_level %in% names(levels))) user_level <- "info"
  if (!(level %in% names(levels))) level <- "info"
  
  if (levels[[user_level]] < levels[[level]]) return(invisible(NULL))
  
  ansi_colored <- function(text, level) {
    switch(level,
           "debug" = paste0("\033[90m", text, "\033[0m"),  # grey
           "info"  = paste0("\033[94m", text, "\033[0m"),  # blue
           "warn"  = paste0("\033[93m", text, "\033[0m"),  # yellow
           "error" = paste0("\033[91m", text, "\033[0m"),  # red
           text)
  }
  
  message(ansi_colored(msg, level))
  
  if (level == "error" && isTRUE(abort)) {
    stop(msg, call. = FALSE)
  }
  
  invisible(NULL)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Internal Helper: Complete Control Object with Defaults ###
#--------------------------------------------------------------------
#' Internal Helper: Complete Control Object with Defaults
#'
#' Fills a partially specified `control` object with default values for all 
#' mandatory components up to the evaluation stage. Optional elements such as 
#' processing engines, reporting, or publishing are only initialized if explicitly 
#' selected by the user.
#'
#' **Purpose:**
#' - Ensures a minimal, runnable workflow configuration even with partial user input.
#' - Enables prototyping or quick-start testing without full manual specification.
#'
#' **Default Behavior:**
#' - Sets `global_seed` to `1` if missing.
#' - Uses `flowengineR::test_data_2_base_credit_example` as fallback data if neither 
#'   `control$data$vars` nor `control$data$full` are provided.
#' - Initializes `data$train` and `data$test` to `NULL` if missing.
#' - Sets `split_method = "split_random_stratified"` and calls `controller_split()` if missing.
#' - Sets `execution = "execution_basic_sequential"` and calls `controller_execution()` if missing.
#' - Sets `train_model = "train_glm"` and `output_type = "response"` if missing.
#' - Calls `controller_training()` if `params$train` is missing.
#' - Adds default evaluation methods if not specified: `"eval_mse"`, `"eval_summarystats"`, `"eval_statisticalparity"`.
#' - Calls `controller_evaluation()` if `params$eval` is missing.
#' - For optional modules (`preprocessing`, `inprocessing`, `postprocessing`, `reportelement`, `report`, `publish`),
#'   corresponding controller functions are only called if the module is selected by the user.
#'
#' **Safety Checks:**
#' - If `control$data$full` is provided without `control$data$vars`, an error is raised.
#' - If `control$data$vars` is provided without `control$data$full`, an error is raised.
#'
#' **Usage Example:**
#' ```r
#' control <- list(train_model = "train_glm")
#' control <- complete_control_with_defaults(control)
#' # returns a runnable control object with defaults and dummy data
#' ```
#'
#' @param control list. A (partially defined) user control object.
#'
#' @return list. A fully structured control object with completed defaults.
#' @keywords internal
complete_control_with_defaults <- function(control) {
  # Ensure control is a list
  if (is.null(control)) control <- list()
  
  # Settings defaults
  if (is.null(control$settings)) control$settings <- list()
  if (is.null(control$settings$log)) control$settings$log <- TRUE
  if (is.null(control$settings$log_level)) control$settings$log_level <- "info"
  
  # Set global seed if not defined
  if (is.null(control$global_seed)) control$global_seed <- 1
  
  # Ensure data list exists
  if (is.null(control$data)) control$data <- list()
  
  # Consistency check for vars and full
  if (is.null(control$data$vars) && !is.null(control$data$full)) {
    stop("If you provide custom data via `data$full`, you must define `data$vars` using controller_vars().")
  }
  if (!is.null(control$data$vars) && is.null(control$data$full)) {
    stop("If you provide custom vars via `data$vars`, you must define `data$full`.")
  }
  
  # Fallback: Dummy data + vars
  if (is.null(control$data$vars) && is.null(control$data$full)) {
    control$data$full <- flowengineR::test_data_2_base_credit_example
    vars <- controller_vars(
      feature_vars = c("income", "loan_amount", "credit_score",
                       "professionEmployee", "professionSelfemployed", "professionUnemployed"),
      protected_vars = c("genderFemale", "genderMale", "age"),
      target_var = "default",
      protected_vars_binary = c("genderFemale", "genderMale",
                                "age_group.<30", "age_group.30-50", "age_group.50+")
    )
    control$data$vars <- vars
  } else {
    vars <- control$data$vars
  }
  
  # Ensure train/test placeholders exist
  if (is.null(control$data$train)) control$data$train <- NULL
  if (is.null(control$data$test)) control$data$test <- NULL
  
  # Split setup
  if (is.null(control$split_method)) control$split_method <- "split_random_stratified"
  if (is.null(control$params$split)) {
    control$params$split <- controller_split()
  }
  
  # Execution setup
  if (is.null(control$execution)) control$execution <- "execution_basic_sequential"
  if (is.null(control$params$execution)) {
    control$params$execution <- controller_execution()
  }
  
  # Training setup
  if (is.null(control$train_model)) control$train_model <- "train_glm"
  if (is.null(control$output_type)) control$output_type <- "response"
  if (is.null(control$params$train)) {
    control$params$train <- controller_training(
      formula = as.formula(paste(
      vars$target_var, "~",
      paste(c(vars$feature_vars, vars$protected_vars), collapse = "+")))
    )
  }
  
  # Evaluation setup
  if (is.null(control$evaluation)) {
    control$evaluation <- list("eval_mse", "eval_summarystats", "eval_statisticalparity")
  }
  if (is.null(control$params$eval)) {
    control$params$eval <- controller_evaluation()
  }
  
  # Optional modules: initialize only if selected
  if (!is.null(control$preprocessing) && is.null(control$params$preprocessing)) {
    control$params$preprocessing <- controller_preprocessing()
  }
  if (!is.null(control$inprocessing) && is.null(control$params$inprocessing)) {
    control$params$inprocessing <- controller_inprocessing()
  }
  if (!is.null(control$postprocessing) && is.null(control$params$postprocessing)) {
    control$params$postprocessing <- controller_postprocessing()
  }
  if (!is.null(control$reportelement) && is.null(control$params$reportelement)) {
    control$params$reportelement <- controller_reportelement()
  }
  if (!is.null(control$report) && is.null(control$params$report)) {
    control$params$report <- controller_report()
  }
  if (!is.null(control$publish) && is.null(control$params$publish)) {
    control$params$publish <- controller_publish()
  }
  
  return(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Helper: List Registered Engines ###
#--------------------------------------------------------------------
#' Helper: List Registered Engines
#'
#' Used throughout the flowengineR-framework to inspect the internal engine
#' registry. Returns all currently registered engines, either grouped by engine
#' type (e.g. "train", "split", "execution") or filtered by a specific type.
#'
#' **Purpose:**
#' - Provides transparency about the active engine configuration.
#' - Useful for debugging, framework introspection, or user-defined extensions.
#'
#' **Usage Example:**
#' ```r
#' # Show all registered engines, grouped by type
#' list_registered_engines()
#'
#' # Show only execution engines
#' list_registered_engines(type = "execution")
#' ```
#'
#' @param type Optional. A character string to filter engines by type prefix (e.g. "train", "split").
#'             If `NULL` (default), all registered engines are returned, grouped by type.
#'
#' @return Either a filtered named list (if `type` is provided), or a named list of engine groups.
#' @export
list_registered_engines <- function(type = NULL) {
  all_engines <- engines
  
  if (!is.null(type)) {
    filtered <- all_engines[grepl(paste0("^", type, "_"), names(all_engines))]
    return(filtered)
  }
  
  split_by_type <- split(
    x = all_engines,
    f = sub("_.*", "", names(all_engines))
  )
  
  return(split_by_type)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Helper: Merge User and Default Hyperparameters ###
#--------------------------------------------------------------------
#' Helper: Merge User and Default Hyperparameters
#'
#' Used throughout the flowengineR-framework to combine user-specified
#' hyperparameters with engine-defined defaults. Ensures that missing fields 
#' in user input are automatically filled with fallback defaults.
#'
#' **Purpose:**
#' - Ensures consistent handling of optional parameters across engines.
#' - Supports robust engine development by avoiding missing parameter errors.
#'
#' **Merging Logic:**
#' - If `user_hyperparameters` is `NULL`, the full set of defaults is returned.
#' - If `user_hyperparameters` is a named list, its elements override the default values.
#'
#' **Usage Example:**
#' ```r
#' user_params <- list(split_ratio = 0.8)
#' default_params <- list(split_ratio = 0.7, seed = 123)
#'
#' merged <- merge_with_defaults(user_params, default_params)
#' # Result: list(split_ratio = 0.8, seed = 123)
#' ```
#'
#' @param user_hyperparameters A named list of parameters provided by the user (may be `NULL`).
#' @param default_hyperparameters A named list of default values defined by the engine.
#'
#' @return A named list containing the merged parameter set.
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
### Helper: Compute Min-Max Normalization Parameters ###
#--------------------------------------------------------------------
#' Internal Helper: Compute Min-Max Normalization Parameters
#'
#' Computes per-feature minimum and maximum values for later use in
#' min-max normalization. Typically applied to training data and reused for
#' test data to ensure consistency.
#'
#' **Usage Context:**
#' - Called by `run_workflow_single()` before applying normalization.
#' - Output is passed to `apply_minmax_params()` to normalize all datasets.
#'
#' **Output Format:**
#' Returns a named list where each entry corresponds to a feature and
#' contains:
#' - `min`: Minimum value of the feature in the training data.
#' - `max`: Maximum value of the feature in the training data.
#'
#' @param data A data frame containing the original (non-normalized) training data.
#' @param feature_names A character vector of numeric features to normalize.
#'
#' @return A named list with `min` and `max` values per feature.
#' @keywords internal
#--------------------------------------------------------------------
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
### Helper: Apply Min-Max Normalization ###
#--------------------------------------------------------------------
#' Internal Helper: Apply Min-Max Normalization
#'
#' Applies min-max normalization to a given data frame using precomputed normalization
#' parameters (typically derived from training data).
#'
#' **Usage Context:**
#' - Used within `run_workflow_single()` to normalize training, test, and model input data.
#' - Ensures consistent normalization across splits and data stages.
#'
#' **Normalization Formula:**
#' \deqn{X_{norm} = \frac{X - X_{min}}{X_{max} - X_{min}}}
#'
#' If a feature has zero range (i.e., `max == min`), its normalized value is set to `0`.
#'
#' @param data A data frame to normalize. Must include all features for which parameters are given.
#' @param params A named list of min/max values per feature (created via `compute_minmax_params()`).
#'
#' @return A data frame with normalized numeric values.
#' @keywords internal
apply_minmax_params <- function(data, params) {
  for (feature in names(params)) {
    if (is.numeric(data[[feature]])) {
      min_val <- params[[feature]]$min
      max_val <- params[[feature]]$max
      if (max_val - min_val != 0) {
        data[[feature]] <- (data[[feature]] - min_val) / (max_val - min_val)
      } else {
        data[[feature]] <- 0  # alternatively: NA or throw warning
      }
    }
  }
  return(data)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Helper: Select Training Data for Engine ###
#--------------------------------------------------------------------
#' Helper: Select Training Data for Engine
#'
#' Retrieves the correct training dataset from the control object 
#' based on whether normalization is enabled or not. This helper 
#' is mandatory for all training engines within the flowengineR-framework.
#'
#' **Purpose:**
#' - Ensures that each training engine uses the correct version of the data 
#'   (`original` vs. `normalized`) based on the normalization setting in the `control` object.
#' - Prevents duplication of selection logic across multiple engines.
#'
#' **Expected Structure:**
#' - `control$params$train$norm_data`: Logical flag indicating if normalized data should be used.
#' - `control$params$train$data`: A list with `original` and `normalized` elements.
#'
#' **Usage Example (inside training engine):**
#' ```r
#' training_data <- select_training_data(control)
#' model <- train(formula = control$params$train$formula, data = training_data, ...)
#' ```
#'
#' @param control The standardized control object passed to the training engine.
#'
#' @return A data frame used for model training.
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
### Helper: Denormalize Predictions ###
#--------------------------------------------------------------------
#' Internal Helper: Denormalize Predictions
#'
#' Transforms numeric predictions made on normalized data back to the original scale
#' using stored min/max values from the training data.
#'
#' **Usage Context:**
#' - Used within `run_workflow_single()` when the prediction output type is `"response"` 
#'   and normalization was applied to the target variable.
#' - Applies inverse of Min-Max scaling based on training data statistics.
#'
#' @param predictions A numeric vector of normalized predictions.
#' @param feature_name Character. Name of the target variable to denormalize.
#' @param norm_params A named list containing min/max values per feature 
#'   (typically created by `compute_minmax_params()`).
#'
#' @return A numeric vector with predictions rescaled to the original target scale.
#' @keywords internal
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
### Helper: Aggregate Evaluation Results ###
#--------------------------------------------------------------------
#' Internal Helper: Aggregate Evaluation Metrics across Splits
#'
#' Aggregates both flat and nested evaluation metrics across multiple splits.
#' This function is used internally by the flowengineR master workflow
#' to compute summary statistics from evaluation outputs.
#'
#' **Usage Context:**
#' - Called by `continue_workflow()` during the aggregation phase.
#' - Supports evaluation outputs with nested or flat metric structures.
#'
#' **Supported Formats:**
#' - Flat metrics (e.g., `mse`, `stat_parity`) → numeric vector across splits.
#' - Nested metrics (e.g., `summary_stats`) → submetric-level mean/sd.
#'
#' @param workflow_results A list of `run_workflow_single()` results (one per split).
#'
#' @return A named list of aggregated metrics, each containing summary statistics.
#' @keywords internal
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
### Helper: Structural Validation of Engine Components ###
#--------------------------------------------------------------------
#' Internal Helper: Validate Engine Wrapper Structure
#'
#' Performs structural consistency checks on engine components within the flowengineR-framework.
#' This includes verifying the existence of required functions (engine, wrapper, default parameters),
#' correct argument signatures, and the use of standardized output initializers.
#'
#' **Purpose:**
#' - Used exclusively in internal validation routines (e.g., `subregistry_validate()`).
#' - Ensures that engine wrappers follow a consistent structure and initialization protocol.
#'
#' **Checks Performed:**
#' - Ensures the existence of `engine_*`, `wrapper_*`, and `default_params_*` functions.
#' - Verifies that the wrapper function has the correct argument signature.
#' - Warns if the wrapper does not call the appropriate `initialize_output_*()` function.
#'
#' **Usage Context:**
#' This function is not intended for end-users or engine developers. It is part of the automated
#' validation mechanism used internally during development.
#'
#' @param wrapper_function The wrapper function to validate.
#' @param engine_name The short engine name (e.g., `"train_glm"`), used to construct expected function names.
#' @param expected_args A character vector of expected formal argument names for the wrapper.
#' @param expected_output_initializer The expected `initialize_output_*` function name (e.g., `"initialize_output_train"`).
#'
#' @return `TRUE` if structure is valid. Otherwise, stops with error or issues warnings.
#' @keywords internal
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



#--------------------------------------------------------------------
### Helper: Display Template for Control Snippets ###
#--------------------------------------------------------------------
#' Internal Helper: Show Control Template for an Engine
#'
#' Loads and optionally prints or opens a prewritten control template file from the
#' `R/` directory of the `flowengineR` package using the naming convention
#' `*_template_<engine>.R`.
#'
#' **Purpose:**
#' - Provides users and developers with ready-to-use example code snippets for control object configuration.
#'
#' **Naming Convention:**
#' - Template filenames must contain `_template_<engine>.R` and be placed in the `R/` folder of the package.
#'
#' **Usage Context:**
#' - Intended for use during development or interactive prototyping.
#'
#' @param name Character. Engine identifier (e.g., `"split_random"` or `"train_lm"`).
#' @param open Logical. If `TRUE`, opens the template in RStudio (if available). Default is `FALSE`.
#' @param return_content Logical. If `TRUE`, returns the template content as character vector. Default is `FALSE`.
#'
#' @return Invisibly returns `TRUE` or, if `return_content = TRUE`, returns character vector. Errors if file not found.
#' @export
#'
#' @examples
#' \dontrun{
#' show_template("split_random")           # Prints to console
#' show_template("split_random", open=TRUE)  # Opens in RStudio
#' text <- show_template("split_random", return_content = TRUE)  # Returns character vector
#' }
show_template <- function(name, open = FALSE, return_content = FALSE) {
  # Locate R/ directory inside installed package
  template_path <- system.file("templates_control", package = "flowengineR")
  if (template_path == "") stop("Could not locate package installation path.")
  
  # Build pattern for matching file with _template_<engine>.R in name
  pattern <- paste0("_template_", name, "\\.R$")
  candidates <- list.files(template_path, full.names = TRUE, pattern = pattern)
  
  if (length(candidates) == 0) {
    stop(sprintf("No template found for engine '%s'. Expected *_template_%s.R in R/ directory.", name, name))
  }
  if (length(candidates) > 1) {
    warning(sprintf("Multiple templates found for '%s'. Using: %s", name, basename(candidates[[1]])))
  }
  
  path <- candidates[[1]]
  
  # Open in RStudio or return/print content
  if (open && rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(path)
    return(invisible(TRUE))
  }
  
  content <- readLines(path, warn = FALSE)
  
  if (return_content) {
    return(content)
  } else {
    cat(paste(content, collapse = "\n"))
    return(invisible(TRUE))
  }
}
#--------------------------------------------------------------------