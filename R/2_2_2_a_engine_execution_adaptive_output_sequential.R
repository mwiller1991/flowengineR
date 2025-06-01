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
#' @seealso [wrapper_execution_adaptive_output_sequential()]
#'
#' @param control A standardized control object including `data$train` and `data$test`.
#'
#' @return Result from `run_workflow_single()`.
#' @keywords internal
engine_execution_adaptive_output_sequential <- function(control) {
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
#' splitter with n_splits = 1 and increasing seeds.
#'
#' **Important Constraint:** Only splitter engines that return **exactly one split** are allowed.
#' Splitters such as cross-validation (`split_cv`) with `cv_folds > 1` are **not supported**.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Execution control settings (e.g., monitored metric, thresholds).
#' - `control`: Full control object.
#' - `split_output`: Initial split result (only used to check validity).
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `metric_name` *(character, default = "mse")*: Metric to monitor.
#' - `metric_source` *(character, default = "eval_mse")*: Evaluation engine providing the metric.
#' - `stability_strategy` *(character)*: Method for convergence (`"custom_relative"`, `"custom_absolute"`, `"mean_relative"`, `"mean_absolute"`, `"sd_relative"`, `"sd_absolute"`, `"mad_relative"`, `"mad_absolute"`, `"cv_relative"`, `"cv_absolute"`, `"cohen_absolute"`).
#' - `threshold` *(numeric)*: Stability threshold for the selected strategy.
#' - `window` *(integer)*: Number of trailing values used to assess stability.
#' - `min_splits` *(integer)*: Minimum number of iterations before checking.
#' - `max_splits` *(integer)*: Maximum iterations before stop.
#' - `seed_base` *(integer)*: Seed base; seed used in iteration `i` is `seed_base + i`.
#' - `custom_stability_function` *(function or NULL)*: Optional user-defined stability function.
#'
#' **Example Control Snippet:**
#' ```
#' control$execution <- "execution_adaptive_output_sequential"
#' control$params$execution <- controller_execution(
#'   params = list(
#'     metric_name = "mse",
#'     stability_strategy = "cohen_absolute",
#'     threshold = 0.2,
#'     window = 3,
#'     min_splits = 5,
#'     max_splits = 50,
#'     seed_base = 1000
#'   )
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/2_2_a_template_execution_adaptive_output_sequential.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_execution()` with:
#' - `execution_type`: "adaptive_output_sequential"
#' - `workflow_results`: List of results from `run_workflow_single()` per split
#' - `params`: Merged parameter list
#' - `continue_workflow`: `TRUE` (workflow continues)
#' - `specific_output`: Includes:
#'     - `metric_name`, `metric_source`
#'     - `values`: Vector of all metric values
#'     - `split_output`: Reconstructed split_output object
#'     - `used_seeds`: Vector of seeds used
#'
#' @seealso 
#'   [engine_execution_adaptive_output_sequential()],  
#'   [default_params_execution_adaptive_output_sequential()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_2_a_template_execution_adaptive_output_sequential.R`
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list containing exactly one data split.
#'
#' @return A standardized execution output object.
#' @keywords internal
wrapper_execution_adaptive_output_sequential <- function(control, split_output) {
  if (length(split_output$splits) != 1) {
    stop(sprintf(
      "Adaptive execution requires a splitter that returns exactly one split. Got %d from '%s'.",
      length(split_output$splits),
      control$split_method
    ))
  }
  
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_adaptive_output_sequential())
  
  strategy_fun <- get(paste0("check_stability_", params$stability_strategy), mode = "function", inherits = TRUE)
  
  workflow_results <- list()
  metric_values <- numeric()
  used_splits <- list()
  used_seeds <- list()
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
    result <- engine_execution_adaptive_output_sequential(control)
    
    # Store results
    workflow_results[[split_id]] <- result
    used_splits[[split_id]] <- split
    used_seeds[[split_id]] <- repeat_seed
    
    # Extract and log metric
    metric_value <- result$output_eval[[params$metric_source]]$metrics[[params$metric_name]]
    metric_values <- c(metric_values, metric_value)
    
    # Compute stability once there is enough data
    if (length(metric_values) >= params$min_splits) {
      stability_result <- strategy_fun(
        values = metric_values,
        threshold = params$threshold,
        window = params$window,
        fun = params$custom_stability_function
      )
    
      required_fields <- c("is_stable", "stability_value", "threshold_value", "strategy")
      if (!all(required_fields %in% names(stability_result))) {
        stop(sprintf("Stability function '%s' must return a list with elements: %s",
                     strategy_id, paste(required_fields, collapse = ", ")))
      }
        
        if (isTRUE(stability_result$is_stable)) {
          message(sprintf(
            "[ADAPTIVE] Stability reached (%s): %.4f < %.4f after %d splits. Stopping.",
            stability_result$strategy,
            stability_result$stability_value,
            stability_result$threshold_value,
            length(metric_values)
          ))
          break
        }
      
      if (length(metric_values) >= params$max_splits) {
        message(sprintf("[ADAPTIVE] Maximum number of splits (%d) reached. Stopping.", params$max_splits))
        break
      }
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
    execution_type = "adaptive_output_sequential",
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
#' Provides default parameters for the `execution_adaptive_output_sequential` engine.
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
#' @seealso [wrapper_execution_adaptive_output_sequential()]
#'
#' @return A named list of default parameters.
#' @keywords internal
default_params_execution_adaptive_output_sequential <- function() {
  list(
    metric_name = "mse",
    metric_source = "eval_mse",
    stability_strategy = "cohen_absolute",
    threshold = 0.2,
    window = 3,
    min_splits = 5,
    max_splits = 50,
    custom_stability_function = NULL,
    seed_base = 1000
  )
}
#--------------------------------------------------------------------