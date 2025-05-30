#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Adaptive Batchtools SLURM Stability
#'
#' Executes a single split using `run_workflow_single()`. Intended for use
#' in adaptive stability procedures, where splits are executed in parallel
#' using batchtools with a SLURM backend.
#'
#' **Inputs (passed via batchtools):**
#' - `control`: A fully prepared control object with assigned training and test data.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_single()`.
#'
#' @param control A standardized control object including `data$train` and `data$test`.
#'
#' @return Result from `run_workflow_single()`.
#' @export
engine_execution_adaptive_output_batchtools_slurm <- function(control) {
  run_workflow_single(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Adaptive Batchtools SLURM Stability
#'
#' Executes batches of 1-split workflows in parallel using `batchtools` (SLURM backend)
#' until a monitored metric becomes stable or a maximum number of iterations is reached.
#' In each iteration, multiple 1-split workflows are launched simultaneously to accelerate
#' the convergence check.
#'
#' **Important Constraint:** Only splitter engines that return **exactly one split** are allowed.
#' Splitters such as cross-validation (`split_cv`) with `cv_folds > 1` are **not supported**.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Parameters for adaptive execution.
#' - `control`: The full control object.
#' - `split_output`: Dummy result of the splitter to validate structure.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "adaptive_output_batchtools_slurm".
#'   - `workflow_results`: Named list of results per split.
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: `TRUE` (ready for next steps).
#'   - `specific_output`: Includes metric values, reconstructed split_output and used seeds.
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list of splits from the splitter engine. Must contain exactly one split.
#'
#' @return A standardized execution output object.
#' @export
wrapper_execution_adaptive_output_batchtools_slurm <- function(control, split_output) {
  if (length(split_output$splits) != 1) {
    stop(sprintf(
      "Adaptive execution requires a splitter that returns exactly one split. Got %d from '%s'.",
      length(split_output$splits),
      control$split_method
    ))
  }
  
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_adaptive_output_batchtools_slurm())
  
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
      split_result <- engines[[control$split_method]](control)
      split <- split_result$splits[[1]]
      
      split_id <- paste0("split", length(metric_values) + j)
      split_batch[[split_id]] <- split
      used_seeds[[split_id]] <- split_seed
      
      tmp_control <- control
      tmp_control$data$train <- split$train
      tmp_control$data$test  <- split$test
      control_batch[[split_id]] <- tmp_control
    }
    
    reg_dir <- file.path(params$registry_folder, paste0("iter_", i))
    unlink(reg_dir, recursive = TRUE)
    reg <- batchtools::makeRegistry(
      file.dir = reg_dir,
      make.default = FALSE,
      seed = params$seed + i,
      packages = params$required_packages
    )
    reg$cluster.functions <- batchtools::makeClusterFunctionsSlurm(template = params$slurm_template)
    registry_dirs <- c(registry_dirs, reg_dir)
    
    batchtools::batchMap(fun = engine_execution_adaptive_output_batchtools_slurm,
                         control = control_batch,
                         reg = reg)
    batchtools::submitJobs(reg = reg, resources = params$resources)
    batchtools::waitForJobs(reg = reg)
    batch_results <- batchtools::reduceResultsList(reg = reg)
    names(batch_results) <- names(split_batch)
    
    for (sid in names(batch_results)) {
      workflow_results[[sid]] <- batch_results[[sid]]
      used_splits[[sid]] <- split_batch[[sid]]
      val <- batch_results[[sid]]$output_eval[[params$metric_source]]$metrics[[params$metric_name]]
      metric_values <- c(metric_values, val)
    }
    
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
        message(sprintf(
          "[ADAPTIVE-SLURM] Stability reached (%s): %.4f < %.4f after %d splits. Stopping.",
          stability_result$strategy,
          stability_result$stability_value,
          stability_result$threshold_value,
          length(metric_values)
        ))
        break
      }
      
      if (length(metric_values) >= params$max_splits) {
        message(sprintf("[ADAPTIVE-SLURM] Maximum number of splits (%d) reached. Stopping.", params$max_splits))
        break
      }
    }
    
    i <- i + 1
  }
  
  reconstructed_split_output <- initialize_output_split(
    split_type = control$split_method,
    splits = used_splits,
    seed = used_seeds,
    params = control$params$split$params,
    specific_output = NULL
  )
  
  initialize_output_execution(
    execution_type = "adaptive_output_batchtools_slurm",
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
#' Default Parameters for Execution Engine: Adaptive Batchtools SLURM Stability
#'
#' Provides default parameters for the `execution_adaptive_output_batchtools_slurm` engine.
#'
#' **Purpose:**
#' - Controls the metric and method used for assessing convergence/stability.
#' - Specifies the batchtools + SLURM configuration.
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
#' - `slurm_template`: Path to a valid SLURM job template.
#' - `seed`: Seed used by batchtools registry.
#' - `required_packages`: Character vector of packages needed on each worker.
#' - `resources`: List passed to `submitJobs()` (e.g. `ncpus`, `memory`, `walltime`).
#'
#' @return A named list of default parameters.
#' @export
default_params_execution_adaptive_output_batchtools_slurm <- function() {
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
    registry_folder = "~/fairness_toolbox/tests/BATCHTOOLS/bt_SLURM_adaptive_output/bt_registry_SLURM",
    slurm_template = "~/fairness_toolbox/tests/BATCHTOOLS/bt_SLURM_adaptive_output/default.tmpl",
    seed = 123,
    required_packages = character(0),
    resources = list(ncpus = 1, memory = 2048, walltime = 3600)
  )
}
#--------------------------------------------------------------------