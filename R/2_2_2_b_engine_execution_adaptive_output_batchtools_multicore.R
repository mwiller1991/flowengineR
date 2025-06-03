#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Adaptive Batchtools Multicore Stability
#'
#' Executes a single split using `run_workflow_singlesplitloop()`. Intended for use
#' in adaptive stability procedures, where splits are executed in parallel
#' using batchtools with a multicore backend.
#'
#' **Inputs (passed via batchtools):**
#' - `control`: A fully prepared control object with assigned training and test data.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_singlesplitloop()`.
#'
#' @seealso [wrapper_execution_adaptive_output_batchtools_multicore()]
#'
#' @param control A standardized control object including `data$train` and `data$test`.
#'
#' @return Result from `run_workflow_singlesplitloop()`.
#' @keywords internal
engine_execution_adaptive_output_batchtools_multicore <- function(control) {
  run_workflow_singlesplitloop(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Adaptive Batchtools Multicore Stability
#'
#' Executes batches of 1-split workflows in parallel using `batchtools` with a multicore backend.  
#' Each batch runs `n_splits_per_iteration` 1-split executions, which are dispatched as jobs and executed concurrently.
#' After each batch, a stability check is performed using a configurable strategy and metric.
#' The process continues until stability is reached or a maximum number of iterations is exceeded.
#'
#' **Important Constraint:**  
#' Only splitter engines that return **exactly one split** are supported.  
#' Splitters such as cross-validation (`split_cv`) with `cv_folds > 1` are **not allowed**.
#'
#' **Standardized Inputs:**
#' - `control`: The full control object.
#' - `split_output`: Dummy result from the splitter to validate structure.
#' - `control$params$execution$params`: Execution-specific configuration (see below).
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `metric_name` *(character, default = "mse")*: Metric to monitor.
#' - `metric_source` *(character, default = "eval_mse")*: Evaluation engine providing the metric.
#' - `stability_strategy` *(character)*: Strategy to assess convergence.  
#'   Allowed values:
#'     `"custom_relative"`, `"custom_absolute"`,  
#'     `"mean_relative"`, `"mean_absolute"`,  
#'     `"sd_relative"`, `"sd_absolute"`,  
#'     `"mad_relative"`, `"mad_absolute"`,  
#'     `"cv_relative"`, `"cv_absolute"`,  
#'     `"cohen_absolute"`
#' - `threshold` *(numeric)*: Stability threshold.
#' - `window` *(integer ≥ 2)*: Number of trailing values for comparison.
#' - `min_splits` *(integer ≥ 1)*: Minimum iterations before checking for stability.
#' - `max_splits` *(integer ≥ min_splits)*: Maximum iterations allowed.
#' - `custom_stability_function` *(function or NULL)*: Optional custom convergence function.
#' - `seed_base` *(integer)*: Base seed; seed for split `i` is `seed_base + i`.
#' - `n_splits_per_iteration` *(integer ≥ 1)*: Number of splits executed per batch (parallel jobs).
#' - `registry_folder` *(character)*: Path to writeable batchtools registry folder.
#' - `seed` *(integer)*: Seed for initializing batchtools registry.
#' - `required_packages` *(character vector)*: Required packages on each job node.
#' - `ncpus` *(integer ≥ 1)*: Number of CPUs used per job.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$execution <- "execution_adaptive_output_batchtools_multicore"
#' control$params$execution <- controller_execution(
#'   params = list(
#'     metric_name = "mse",
#'     metric_source = "eval_mse",
#'     stability_strategy = "cohen_absolute",
#'     threshold = 0.2,
#'     window = 3,
#'     min_splits = 5,
#'     max_splits = 50,
#'     seed_base = 2000,
#'     n_splits_per_iteration = 3,
#'     registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_registry_adaptive_output_multicore",
#'     seed = 123,
#'     required_packages = c("caret", "dplyr"),
#'     ncpus = 4
#'   )
#' )
#' ```
#'
#' **Template Reference:**  
#' See full template in `inst/templates_control/2_2_b_template_execution_adaptive_output_batchtools_multicore.R`
#'
#' **Standardized Output (returned to framework):**
#' A list as created by `initialize_output_execution()`:
#' - `execution_type`: `"adaptive_output_batchtools_multicore"`
#' - `workflow_results`: List of results from `run_workflow_singlesplitloop()` per split
#' - `params`: All resolved execution parameters
#' - `continue_workflow`: Always `TRUE`
#' - `specific_output`: Includes:
#'     - `metric_name`, `metric_source`
#'     - `values`: Vector of all monitored metric values
#'     - `split_output`: Combined `initialize_output_split()` result
#'     - `used_seeds`: List of all used seeds
#'
#' @seealso 
#'   [engine_execution_adaptive_output_batchtools_multicore()],  
#'   [default_params_execution_adaptive_output_batchtools_multicore()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_2_b_template_execution_adaptive_output_batchtools_multicore.R`
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list containing exactly one split.
#'
#' @return A standardized execution output object.
#' @keywords internal
wrapper_execution_adaptive_output_batchtools_multicore <- function(control, split_output) {
  log_msg("[EXECUTION] Starting adaptive batchtools execution...", level = "info", control = control)
  
  if (length(split_output$splits) != 1) {
    stop(sprintf(
      "Adaptive execution requires a splitter that returns exactly one split. Got %d from '%s'.",
      length(split_output$splits),
      control$engine_select$split
    ))
  }
  
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_adaptive_output_batchtools_multicore())
  
  strategy_fun <- get(paste0("check_stability_", params$stability_strategy), mode = "function", inherits = TRUE)
  
  workflow_results <- list()
  metric_values <- numeric()
  used_splits <- list()
  used_seeds <- list()
  i <- 1
  registry_dirs <- c()
  
  repeat {
    seeds <- params$seed_base + ((i - 1) * params$n_splits_per_iteration + 1):(i * params$n_splits_per_iteration)
    split_batch <- list()
    control_batch <- list()
    
    for (j in seq_along(seeds)) {
      split_seed <- seeds[j]
      control$params$split$seed <- split_seed
      split_result <- engines[[control$engine_select$split]](control)
      split <- split_result$splits[[1]]
      
      split_id <- paste0("split", length(metric_values) + j)
      split_batch[[split_id]] <- split
      used_seeds[[split_id]] <- split_seed
      
      tmp_control <- control
      tmp_control$data$train <- split$train
      tmp_control$data$test  <- split$test
      control_batch[[split_id]] <- tmp_control
    }
    
    # Create a new registry per iteration
    reg_dir <- file.path(params$registry_folder, paste0("iter_", i))
    unlink(reg_dir, recursive = TRUE)
    reg <- batchtools::makeRegistry(
      file.dir = reg_dir,
      make.default = FALSE,
      seed = params$seed + i,
      packages = params$required_packages
    )
    reg$cluster.functions <- batchtools::makeClusterFunctionsMulticore(ncpus = params$ncpus)
    registry_dirs <- c(registry_dirs, reg_dir)
    
    # Map and run
    batchtools::batchMap(fun = engine_execution_adaptive_output_batchtools_multicore,
                         control = control_batch,
                         reg = reg)
    batchtools::submitJobs(reg = reg)
    batchtools::waitForJobs(reg = reg)
    batch_results <- batchtools::reduceResultsList(reg = reg)
    names(batch_results) <- names(split_batch)
    
    for (sid in names(batch_results)) {
      workflow_results[[sid]] <- batch_results[[sid]]
      used_splits[[sid]] <- split_batch[[sid]]
      val <- batch_results[[sid]]$output_eval[[params$metric_source]]$metrics[[params$metric_name]]
      metric_values <- c(metric_values, val)
    }
    
    # Check stability
    if (length(metric_values) >= params$min_splits) {
      stability_result <- strategy_fun(
        values = metric_values,
        threshold = params$threshold,
        window = params$window,
        fun = params$custom_stability_function
      )
      
      if (!all(c("is_stable", "stability_value", "threshold_value", "strategy") %in% names(stability_result))) {
        stop("Invalid output from stability function.")
      }
      
      if (isTRUE(stability_result$is_stable)) {
        log_msg(sprintf(
          "[EXECUTION] Stability reached (%s): %.4f < %.4f after %d splits. Stopping.",
          stability_result$strategy,
          stability_result$stability_value,
          stability_result$threshold_value,
          length(metric_values)
        ), level = "info", control = control)
        break
      }
      
      if (length(metric_values) >= params$max_splits) {
        log_msg(sprintf("[EXECUTION] Maximum number of splits (%d) reached. Stopping.", params$max_splits),
                level = "warning", control = control)
        break
      }
    }
    
    i <- i + 1
  }
  
  reconstructed_split_output <- initialize_output_split(
    split_type = control$engine_select$split,
    splits = used_splits,
    seed = used_seeds,
    params = control$params$split$params,
    specific_output = NULL
  )
  
  initialize_output_execution(
    execution_type = "adaptive_output_batchtools_multicore",
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
#' Default Parameters for Execution Engine: Adaptive Batchtools Multicore Stability
#'
#' Provides default parameters for the `execution_adaptive_output_batchtools_multicore` engine.
#'
#' **Purpose:**
#' - Controls the metric and method used for assessing convergence/stability.
#' - Specifies the batchtools environment for parallel execution.
#'
#' **Default Parameters:**
#' - `metric_name`: Metric name to monitor (default: `"mse"`).
#' - `metric_source`: Evaluation engine used (default: `"eval_mse"`).
#' - `stability_strategy`: Method used to assess convergence (`"sd"`, `"cv"`, `"mad"`, `"mean"` or `"custom"`).
#' - `threshold`: Threshold value for the selected stability strategy.
#' - `window`: Number of trailing values to compare.
#' - `min_splits`: Minimum number of iterations before checking for stability.
#' - `max_splits`: Maximum allowed iterations before forced stop.
#' - `custom_stability_function`: Optional user-defined function to override built-in criteria.
#' - `seed_base`: Base seed value. Seeds are incremented per batch (e.g., `seed_base + i`).
#' - `n_splits_per_iteration`: Number of splits per iteration (parallelized).
#' - `registry_folder`: Path to the batchtools registry.
#' - `seed`: Seed used by batchtools registry.
#' - `required_packages`: Character vector of packages needed on each worker.
#' - `ncpus`: Number of local CPUs used per job (multicore backend).
#'
#' @seealso [wrapper_execution_adaptive_output_batchtools_multicore()]
#'
#' @return A named list of default parameters.
#' @keywords internal
default_params_execution_adaptive_output_batchtools_multicore <- function() {
  list(
    metric_name = "mse",
    metric_source = "eval_mse",
    stability_strategy = "cohen_absolute",
    threshold = 0.2,
    window = 3,
    min_splits = 5,
    max_splits = 50,
    custom_stability_function = NULL,
    seed_base = 2000,
    n_splits_per_iteration = 3,
    registry_folder = "~/flowengineR/tests/BATCHTOOLS/bt_registry_adaptive_output_multicore",
    seed = 123,
    required_packages = character(0),
    ncpus = parallel::detectCores()
  )
}
#--------------------------------------------------------------------