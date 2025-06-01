# ============================================================
# Template for Execution Engine: execution_adaptive_output_batchtools_multicore
# ============================================================

# 1. Engine Selection
control$execution <- "execution_adaptive_output_batchtools_multicore"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    metric_name = "mse",                  # Metric to monitor (must be returned by evaluation engine)
    metric_source = "eval_mse",           # ID of the engine providing the metric
    stability_strategy = "cohen_absolute",# Stability check method (see full list below)
    threshold = 0.2,                      # Threshold value for convergence
    window = 3,                           # Number of trailing values used in stability check
    min_splits = 5,                       # Minimum number of splits before stability is assessed
    max_splits = 50,                      # Hard cap on number of iterations
    custom_stability_function = NULL,     # Optional function(values, threshold, window, fun)
    seed_base = 2000,                     # Base seed (split i uses seed_base + i)
    n_splits_per_iteration = 3,           # Number of splits per iteration (i.e., parallel jobs)
    registry_folder = "~/bt_registries/output_bt_multicore", # Must be writeable
    seed = 123,                           # Random seed used for registry setup
    required_packages = c("caret", "dplyr"), # Ensure all dependencies are loaded per job
    ncpus = 4                             # Number of cores per parallel job (multicore backend)
  )
)

# --- Available Parameters for execution_adaptive_output_batchtools_multicore ---
# metric_name: Character, e.g., "mse", "statisticalparity"
# metric_source: Character ID of the evaluation engine
# stability_strategy:
#   "custom_relative", "custom_absolute",
#   "mean_relative", "mean_absolute",
#   "sd_relative", "sd_absolute",
#   "mad_relative", "mad_absolute",
#   "cv_relative", "cv_absolute",
#   "cohen_absolute"
# threshold: Numeric, threshold for convergence detection
# window: Integer ≥ 2, size of moving window
# min_splits: Integer ≥ 1, required before stability check
# max_splits: Integer ≥ min_splits, hard stop
# custom_stability_function: Optional override (function or NULL)
# seed_base: Integer base seed
# n_splits_per_iteration: Integer ≥ 1, jobs per iteration
# registry_folder: Path to batchtools registry (write permissions required)
# seed: Integer, registry RNG seed
# required_packages: Character vector, packages needed on each job node
# ncpus: Integer ≥ 1, number of cores per job
#
# Notes:
# - Only compatible with splitters that return **exactly one split**
# - Designed for use with parallel execution workflows (via `batchtools`)
# - Reconstructed `split_output` allows reporting to work as usual