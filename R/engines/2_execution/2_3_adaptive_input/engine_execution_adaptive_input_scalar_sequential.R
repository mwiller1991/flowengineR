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
#' @param control A standardized control object including `data$train`, `data$test`,
#'                and updated parameter (via `param_path`).
#'
#' @return Result from `run_workflow_single()`.
#' @export
engine_execution_adaptive_input_scalar_sequential <- function(control) {
  run_workflow_single(control)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Execution Engine: Adaptive Scalar Param Optimization (Sequential)
#'
#' Optimizes a single scalar hyperparameter by incrementally adjusting its value
#' and monitoring a specified evaluation metric (e.g. MSE). The process stops when
#' no relevant improvement is observed or a maximum number of iterations is reached.
#'
#' **Standardized Inputs:**
#' - `control$params$execution$params`: Parameters controlling the optimization.
#' - `control`: Full control object.
#' - `split_output`: Split result (only the first split is used throughout).
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_execution()`:
#'   - `execution_type`: "adaptive_input_scalar_sequential".
#'   - `workflow_results`: Named list of results per iteration.
#'   - `params`: Merged parameter list.
#'   - `continue_workflow`: `TRUE`.
#'   - `specific_output`: Includes metric values, param values, best result, and best param.
#'
#' @param control A standardized control object (see `controller_execution()`).
#' @param split_output A list of splits from the splitter engine (must contain at least one).
#'
#' @return A standardized execution output object.
#' @export
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
#' @return A named list.
#' @export
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