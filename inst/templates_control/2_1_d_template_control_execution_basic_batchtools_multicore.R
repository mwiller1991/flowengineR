# ============================================================
# Template for Execution Engine: execution_basic_batchtools_multicore
# ============================================================

# 1. Engine Selection
control$execution <- "execution_basic_batchtools_multicore"

# 2. Execution Parameters
control$params$execution <- controller_execution(
  params = list(
    registry_folder = "~/fairness_toolbox/tests/BATCHTOOLS/bt_registry_basic_multicore", # Target registry folder
    seed = 42,                   # Seed for reproducibility
    ncpus = 4,                   # Number of CPU cores to use in parallel
    required_packages = character(0)  # Add required packages here, e.g., c("ggplot2", "caret")
  )
)

# --- Available Parameters for execution_basic_batchtools_multicore ---
# registry_folder: Character string path to batchtools registry directory.
# seed: Integer seed for reproducibility.
# ncpus: Integer number of parallel processes to run (recommended ≤ number of physical cores).
# required_packages: Character vector of R packages to preload in each worker.
#
# Notes:
# - This engine uses batchtools with `makeClusterFunctionsMulticore()`.
# - Only available on Unix-like systems (Linux, macOS, WSL). Not supported on Windows.
# - You can monitor progress via the batchtools registry located in `registry_folder`.