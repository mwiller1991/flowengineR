#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Adaptive Sequential Stability
#'
#' Executes a single split using `run_workflow_single()`. Intended for use in adaptive loops
#' where each split is executed sequentially with increasing seeds.
#'
#' **Inputs (passed via wrapper):**
#' - `control`: A fully prepared control object with assigned training and test data.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_single()`.
#'
#' @param control A standardized control object including `data$train` and `data$test`.
#'
#' @return Result from `run_workflow_single()`.
#' @export
engine_execution_adaptive_sequential_stability <- function(control) {
  run_workflow_single(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Adaptive Sequential Stability
#'
#' Executes a dynamic number of 1-split workflows until a monitored metric becomes stable
#' or a maximum number of iterations is reached. Splits are generated using the configured
#' splitter with `n_splits = 1` and increasing seeds.
#'
#' **Important Constraint:** Only splitter engines that return **exactly one split** are allowed.
#' Splitters such as cross-validation (`split_cv`) with `cv_folds > 1` are **not supported**.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Parameters for adaptive execution.
#' - `control`: The full control object.
#' - `split_output`: The result of the initial splitter call (used only to validate split count).
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "adaptive_stability".
#'   - `workflow_results`: Named list of results per iteration.
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: `TRUE` (ready for next steps).
#'   - `specific_output`: Includes metric values, reconstructed split_output and used seeds.
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list of splits from the splitter engine. Must contain exactly one split.
#'
#' @return A standardized execution output object.
#' @export
wrapper_execution_adaptive_sequential_stability <- function(control, split_output) {
  if (length(split_output$splits) != 1) {
    stop(sprintf(
      "Adaptive execution requires a splitter that returns exactly one split. Got %d from '%s'.",
      length(split_output$splits),
      control$split_method
    ))
  }
  
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_adaptive_sequential_stability())
  
  # Extract and validate stability threshold
  stability_criterion <- params$stability_criterion
  stability_threshold <- params$thresholds[[stability_criterion]]
    if (!is.list(stability_threshold) || !all(c("type", "value") %in% names(stability_threshold))) {
      stop(sprintf("Threshold for '%s' must be a list with 'type' and 'value'.", stability_criterion))
    }
  
  type = "relative"
  stability_threshold_type <- stability_threshold$type
  stability_threshold_value <- stability_threshold$value
    if (!is.logical(stability_threshold_type) || length(stability_threshold_type) != 1) {
      stop(sprintf("Threshold for '%s': 'relative_threshold' must be a single logical value.", stability_criterion))
    } #adjust to new format, must be relative, absolute or sd
    if (!is.null(stability_threshold_value) && !is.numeric(stability_threshold_value)) {
      stop(sprintf("Threshold for '%s': 'value' must be numeric or NULL.", stability_criterion))
    }
  
  # Reduce param set to selected criterion
  params$thresholds <- setNames(list(stability_threshold), stability_criterion)
  
  workflow_results <- list()
  metric_values <- numeric()
  used_splits <- list()
  used_seeds <- list()
  stability_value <- NA
  i <- 1
  
  repeat {
    repeat_seed <- params$seed_base + i
    control$params$split$seed <- repeat_seed
    
    split_result <- engines[[control$split_method]](control)
    split <- split_result$splits[[1]]
    split_id <- paste0("split", i)
    
    # Set split into control
    control$data$train <- split$train
    control$data$test <- split$test
    
    # Run workflow
    result <- engine_execution_adaptive_sequential_stability(control)
    
    # Store results
    workflow_results[[split_id]] <- result
    used_splits[[split_id]] <- split
    used_seeds[[split_id]] <- repeat_seed
    
    # Extract and log metric
    metric_value <- result$output_eval[[params$metric_source]]$metrics[[params$metric_name]]
    metric_values <- c(metric_values, metric_value)
    
    # Compute stability once there is enough data
    if (length(metric_values) >= params$min_splits) {
      global_vec  <- metric_values
      window_vec  <- tail(metric_values, params$window)
      
      # Set threshold as SD if wanted
      if (stability_threshold_type == "sd") {
        stability_threshold_value <- abs(sd(global_vec))
      }
      
      if (stability_criterion == "custom") {
        custom_f <- params$custom_stability_function
          if (!is.function(custom_f)) {
            stop("Custom stability function is not a valid function.")
          }
        
        stability_value <- abs(custom_f(window_vec) - custom_f(global_vec))
        
        if (!is.numeric(stability_value) || length(stability_value) != 1) {
          stop("Custom stability function must return a single numeric value.")
        }
      } else {
        stability_value <- switch(
          stability_criterion,
          sd          = abs(sd(window_vec) - sd(global_vec)),
          cv          = abs((sd(window_vec)/mean(window_vec)) - (sd(global_vec)/mean(global_vec))),
          mad         = abs(mad(window_vec) - mad(global_vec)),
          mean        = abs(mean(window_vec) - mean(global_vec)),
          stop("Unknown stability_criterion: ", stability_criterion)
        )
      }
      
      # Apply relative transformation if needed
      if (stability_threshold_relative) {
        if (stability_criterion == "custom") {
          base_value <- abs(custom_f(global_vec))
        } else {
          base_value <- switch(
            stability_criterion,
            sd          = abs(sd(global_vec)),
            cv          = abs((sd(global_vec)/mean(global_vec))),
            mad         = abs(mad(global_vec)),
            mean        = abs(mean(global_vec))
          )
        }
        if (base_value == 0) base_value <- 1e-8  # prevent division by zero
        stability_value <- abs(stability_value / base_value)
      }
      
      # Message and stopping
      if (!is.na(stability_value) && stability_value < stability_threshold_value) {
        type_label <- if (stability_threshold_relative) " (relative)" else " (absolute)"
        message(sprintf(
          "[ADAPTIVE] Stability threshold%s for '%s' reached: %.4f < %.4f after %d splits. Stopping.",
          type_label, stability_criterion, stability_value, stability_threshold_value, length(metric_values)
        ))
        break
      }
    }
    
    if (length(metric_values) >= params$max_splits) {
      message(sprintf("[ADAPTIVE] Maximum number of splits (%d) reached. Stopping.", params$max_splits))
      break
    }
    
    i <- i + 1
  }
  
  # Rebuild standardized split_output
  reconstructed_split_output <- initialize_output_split(
    split_type = control$split_method,
    splits = used_splits,
    seed = used_seeds,
    params = control$params$split$params,
    specific_output = NULL
  )
  
  # Return execution output
  initialize_output_execution(
    execution_type = "adaptive_stability",
    workflow_results = workflow_results,
    params = params,
    continue_workflow = TRUE,
    specific_output = list(
      metric_name = params$metric_name,
      metric_source = params$metric_source,
      values = metric_values,
      split_output = reconstructed_split_output,
      used_seeds = used_seeds
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Adaptive Sequential Stability
#'
#' Provides default parameters for the `execution_adaptive_sequential_stability` engine.
#'
#' **Purpose:**
#' - Controls the metric and method used for assessing convergence/stability.
#'
#' **Default Parameters:**
#' - `metric_name`: Metric name to monitor (default: `"mse"`).
#' - `metric_source`: Evaluation engine used (default: `"eval_mse"`).
#' - `stability_criterion`: Method used to assess convergence (`"sd"`, `"cv"`, `"mad"`, `"mean"` or `"custom"`).
#' - `thresholds`: Named list of thresholds for each supported criterion.
#' - `window`: Number of trailing values to compare.
#' - `min_splits`: Minimum number of iterations before checking for stability.
#' - `max_splits`: Maximum allowed iterations before forced stop.
#' - `custom_stability_function`: Optional user-defined function to override built-in criteria.
#' - `seed_base`: Base seed value. The actual seed in iteration i is `seed_base + i`.
#'
#' @return A named list of default parameters.
#' @export
default_params_execution_adaptive_sequential_stability <- function() {
  list(
    metric_name = "mse",
    metric_source = "eval_mse",
    stability_criterion = "cv",
    thresholds = list(
      sd = list(type = "relative", value = 0.01),
      cv = list(type = "absolute" = FALSE, value = 0.02),
      mad = list(type = "sd" = FALSE, value = NULL),
      mean = list(type = "relative", value = 0.01),
      custom = list(type = "relative", value = NULL)
    ),
    window = 3,
    min_splits = 5,
    max_splits = 50,
    custom_stability_function = NULL,
    seed_base = 1000
  )
}
#--------------------------------------------------------------------