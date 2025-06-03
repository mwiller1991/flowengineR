# ============================================================
# Template for Execution Engine: execution_adaptive_output_batchtools_slurm
# ============================================================

# 1. Engine Selection
control$engine_select$execution <- "execution_adaptive_output_batchtools_slurm"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    metric_name = "mse",                  # Metric to monitor
    metric_source = "eval_mse",           # Evaluation engine providing metric
    stability_strategy = "cohen_absolute",# Convergence strategy (see list below)
    threshold = 0.2,                      # Stability threshold
    window = 3,                           # Trailing window size for check
    min_splits = 5,                       # Minimum iterations before checking
    max_splits = 50,                      # Maximum iterations (hard stop)
    custom_stability_function = NULL,     # Optional override for built-in checks
    seed_base = 2000,                     # Base seed, ensures reproducibility
    n_splits_per_iteration = 3,           # Number of jobs launched per iteration
    registry_folder = "~/bt_SLURM/registry",   # Must be writeable on submit node
    slurm_template = "~/bt_SLURM/default.tmpl",# SLURM job template
    seed = 123,                           # Registry initialization seed
    required_packages = c("caret", "dplyr"),   # Load on each worker
    resources = list(                     # SLURM job configuration
      ncpus = 2,
      memory = 4096,
      walltime = 3600
    )
  )
)

# --- Available Parameters for execution_adaptive_output_batchtools_slurm ---
# metric_name: Character, e.g., "mse"
# metric_source: Character, e.g., "eval_mse"
# stability_strategy: One of:
#   "custom_relative", "custom_absolute",
#   "mean_relative", "mean_absolute",
#   "sd_relative", "sd_absolute",
#   "mad_relative", "mad_absolute",
#   "cv_relative", "cv_absolute",
#   "cohen_absolute"
# threshold: Numeric, convergence threshold
# window: Integer ≥ 2
# min_splits: Integer ≥ 1
# max_splits: Integer ≥ min_splits
# seed_base: Integer base for split-specific seeds
# n_splits_per_iteration: Integer ≥ 1
# registry_folder: Path to batchtools registry (writeable)
# slurm_template: Path to SLURM template (*.tmpl)
# seed: Integer used for registry RNG
# required_packages: Vector of packages to load on each job
# resources: List with SLURM resource specs (e.g. ncpus, memory, walltime)

# Notes:
# - This engine is designed for use in SLURM cluster environments.
# - Splitter must return exactly one split.
# - Results can be post-processed by reporting engines as usual.