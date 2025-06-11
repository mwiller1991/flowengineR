# ============================================================
# Template for Execution Engine: execution_adaptive_input_scalar_sequential
# ============================================================

# 1. Engine Selection
control$engine_select$execution <- "execution_adaptive_input_scalar_sequential"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    param_path = "train$params$ntree",   # Path to scalar param (dot/`$` notation inside control)
    param_start = 10,                      # Initial value for param
    param_step = 10,                       # Step size between iterations
    direction = "minimize",                # Either "minimize" or "maximize"
    metric_name = "mse",                   # Metric to monitor for performance
    metric_source = "eval_mse",            # Evaluation engine returning the metric
    min_improvement = 0.001,               # Minimum gain required to continue
    max_iterations = 10                    # Max number of optimization steps
  )
)

# --- Available Parameters for execution_adaptive_input_scalar_sequential ---
# param_path: Character, R-access path to scalar parameter (e.g., "train_params$ntree")
# param_start: Numeric, starting value for optimization
# param_step: Numeric, increment for each step
# direction: "minimize" or "maximize"
# metric_name: Name of the metric to be optimized
# metric_source: ID of the evaluation engine (e.g. "eval_mse")
# min_improvement: Numeric threshold for stopping
# max_iterations: Maximum steps before stopping (integer ≥ 1)
#
# Notes:
# - Only the first split from the splitter is used for all runs.
# - Best result and parameter value are returned in `specific_output`.