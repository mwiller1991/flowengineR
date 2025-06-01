#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Execution Engine: Adaptive Scalar Param Optimization (Sequential)
#'
#' Executes a single run using `run_workflow_single()`, designed for use
#' in scalar hyperparameter optimization. This engine is called internally
#' by the sequential wrapper to test one specific parameter value.
#'
#' **Inputs (passed via wrapper):**
#' - `control`: A fully prepared control object with fixed train/test data
#'              and one scalar parameter set to a candidate value.
#'
#' **Output (returned to wrapper):**
#' - A single result list as returned by `run_workflow_single()`.
#'
#' @seealso [wrapper_execution_adaptive_input_scalar_sequential()]
#'
#' @param control A standardized control object including `data$train`, `data$test`,
#'                and updated parameter (via `param_path`).
#'
#' @return Result from `run_workflow_single()`.
#' @keywords internal
engine_execution_adaptive_input_scalar_sequential <- function(control) {
  run_workflow_single(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Adaptive Scalar Param Optimization (Sequential)
#'
#' Optimizes a single numeric/scalar hyperparameter in sequential steps.  
#' In each iteration, the value is updated and `run_workflow_single()` is called with the adjusted `control` object.  
#' The process stops when the performance metric no longer improves sufficiently, or when the maximum number of steps is reached.
#'
#' **Standardized Inputs:**
#' - `control`: Full control object.
#' - `split_output`: Output of the splitter engine. Only the **first split** is used for all runs.
#' - `control$params$execution$params`: Engine-specific settings.
#'
#' **Engine-Specific Parameters (`control$params$execution$params`):**
#' - `param_path` *(character)*: Path to the scalar parameter to optimize (e.g., `"train_params$n.trees"`).
#' - `param_start` *(numeric)*: Starting value of the parameter.
#' - `param_step` *(numeric)*: Increment to apply in each iteration.
#' - `direction` *(character)*: Either `"minimize"` or `"maximize"` the metric.
#' - `metric_name` *(character)*: Metric to monitor.
#' - `metric_source` *(character)*: ID of the evaluation engine returning the metric.
#' - `min_improvement` *(numeric)*: Minimum required improvement to continue.
#' - `max_iterations` *(integer ≥ 1)*: Maximum number of optimization steps.
#'
#' **Example Control Snippet:**
#' ```
#' control$execution <- "execution_adaptive_input_scalar_sequential"
#' control$params$execution <- controller_execution(
#'   params = list(
#'     param_path = "train_params$n.trees",
#'     param_start = 10,
#'     param_step = 10,
#'     direction = "minimize",
#'     metric_name = "mse",
#'     metric_source = "eval_mse",
#'     min_improvement = 0.001,
#'     max_iterations = 10
#'   )
#' )
#' ```
#'
#' **Template Reference:**  
#' See `inst/templates_control/2_3_a_template_execution_adaptive_input_scalar_sequential.R`
#'
#' **Standardized Output (returned to framework):**
#' Created via `initialize_output_execution()`:
#' - `execution_type`: `"adaptive_input_scalar_sequential"`
#' - `workflow_results`: List of results per parameter value
#' - `params`: Final execution parameter list
#' - `continue_workflow`: Always `TRUE`
#' - `specific_output`: Includes:
#'     - `metric_name`, `metric_source`
#'     - `values`: Vector of metric values
#'     - `param_values`: Tested parameter values
#'     - `best_metric`: Best metric value
#'     - `best_param`: Corresponding best parameter value
#'     - `best_result`: Full result object from best run
#'
#' @seealso 
#'   [engine_execution_adaptive_input_scalar_sequential()],  
#'   [default_params_execution_adaptive_input_scalar_sequential()],  
#'   [initialize_output_execution()],  
#'   [controller_execution()],  
#'   Template: `inst/templates_control/2_3_a_template_execution_adaptive_input_scalar_sequential.R`
#'
#' @param control A standardized control object.
#' @param split_output A list with at least one split, of which the first is used.
#'
#' @return A standardized execution output object.
#' @keywords internal
wrapper_execution_adaptive_input_scalar_sequential <- function(control, split_output) {
  params <- merge_with_defaults(control$params$execution$params, default_params_execution_adaptive_input_scalar_sequential())
  
  metric_values <- numeric()
  param_values <- numeric()
  workflow_results <- list()
  
  split <- split_output$splits[[1]]
  control$data$train <- split$train
  control$data$test  <- split$test
  
  current_value <- params$param_start
  best_metric <- if (params$direction == "minimize") Inf else -Inf
  best_result <- NULL
  best_param <- NULL
  
  for (i in seq_len(params$max_iterations)) {
    param_values[i] <- current_value
    split_id <- paste0("param", i)
    
    # Set value via dynamic assignment
    eval(parse(text = paste0("control$", params$param_path, " <- ", current_value)))
    
    result <- run_workflow_single(control)
    workflow_results[[split_id]] <- result
    metric <- result$output_eval[[params$metric_source]]$metrics[[params$metric_name]]
    metric_values[i] <- metric
    
    improve <- if (params$direction == "minimize") (best_metric - metric) else (metric - best_metric)
    
    if (improve > params$min_improvement) {
      best_metric <- metric
      best_result <- result
      best_param <- current_value
      current_value <- current_value + params$param_step
    } else {
      message(sprintf(
        "[PARAMOPT] No further improvement after %d iterations (best = %.4f). Stopping.",
        i, best_metric
      ))
      break
    }
  }
  
  initialize_output_execution(
    execution_type = "adaptive_input_scalar_sequential",
    workflow_results = workflow_results,
    params = params,
    continue_workflow = TRUE,
    specific_output = list(
      metric_name = params$metric_name,
      metric_source = params$metric_source,
      values = metric_values,
      param_values = param_values,
      best_metric = best_metric,
      best_param = best_param,
      best_result = best_result
    )
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Execution Engine: Adaptive Scalar Param Optimization (Sequential)
#'
#' Controls the scalar parameter search loop to optimize an evaluation metric.
#'
#' **Default Parameters:**
#' - `param_path`: Path to the parameter inside control (e.g. `"train_params$n.trees"`).
#' - `param_start`: Initial value (numeric).
#' - `param_step`: Step size (numeric).
#' - `direction`: `"minimize"` or `"maximize"`.
#' - `metric_name`: Name of the evaluation metric.
#' - `metric_source`: Evaluation engine key (e.g. `"eval_mse"`).
#' - `min_improvement`: Minimum required improvement to continue.
#' - `max_iterations`: Max allowed steps.
#'
#' @seealso [wrapper_execution_adaptive_input_scalar_sequential()]
#'
#' @return A named list.
#' @keywords internal
default_params_execution_adaptive_input_scalar_sequential <- function() {
  list(
    param_path = "train_params$n.trees",
    param_start = 10,
    param_step = 10,
    direction = "minimize",
    metric_name = "mse",
    metric_source = "eval_mse",
    min_improvement = 0.001,
    max_iterations = 10
  )
}
#--------------------------------------------------------------------