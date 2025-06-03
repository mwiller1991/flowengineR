# ============================================================
# Template for Training Engine: train_lm
# ============================================================

# 1. Engine Selection
control$engine_select$train <- "train_lm"

# 2. Training Parameters
control$params$train <- controller_train(
  formula = target ~ .,      # R formula specifying model structure
  norm_data = TRUE           # If TRUE, the workflow uses normalized data
  # params = list()          # Not required for lm engine
)

# --- Available Parameters for train_lm ---
# formula: Formula object (e.g., target ~ .)
# norm_data: Logical, TRUE = use normalized data from workflow
# params: Not used (empty list by default)
#
# Notes:
# - Data is automatically injected by the workflow (do not provide manually)
# - Engine calls stats::lm()
# - Execution time is returned via specific_output
