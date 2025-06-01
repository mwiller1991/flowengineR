# ============================================================
# Template for Execution Engine: execution_adaptive_output_sequential
# ============================================================

# 1. Engine Selection
control$execution <- "execution_adaptive_output_sequential"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    metric_name = "mse",             # Metric to monitor (must be returned by evaluation engine)
    metric_source = "eval_mse",      # Evaluation engine used
    stability_strategy = "cohen_absolute",  # Strategy (e.g., "sd", "cv", "mad", "cohen_absolute")
    threshold = 0.2,                 # Convergence threshold
    window = 3,                      # Size of trailing comparison window
    min_splits = 5,                  # Minimum iterations before convergence check
    max_splits = 50,                 # Maximum number of iterations allowed
    seed_base = 1000,                # Base seed; actual seeds are seed_base + i
    custom_stability_function = NULL # Optional user-defined function
  )
)

# --- Available Parameters for execution_adaptive_output_sequential ---
# metric_name: Character, e.g., "mse", "statisticalparity"
# metric_source: Character ID of the evaluation engine, e.g., "eval_mse"
# stability_strategy:
#   "custom_relative", "custom_absolute",
#   "mean_relative", "mean_absolute",
#   "sd_relative", "sd_absolute",
#   "mad_relative", "mad_absolute",
#   "cv_relative", "cv_absolute",
#   "cohen_absolute"
# threshold: Numeric value used as convergence threshold
# window: Number of splits in the moving window (≥ 2)
# min_splits: Minimum number of iterations before convergence is assessed
# max_splits: Hard stop after this number of iterations
# seed_base: Integer base for deterministic seed variation (i → seed_base + i)
# custom_stability_function: Function(values, threshold, window, fun) → list(is_stable, ...)
#
# Notes:
# - Requires splitter that returns exactly 1 split.
# - Cannot be used with CV splitters or multi-fold configurations.
# - Reconstructed split_output is returned to allow reporting engines to function normally.