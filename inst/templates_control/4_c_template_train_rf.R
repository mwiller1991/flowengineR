
# ============================================================
# Template for Training Engine: train_rf
# ============================================================

# 1. Engine Selection
control$engine_select$train <- "train_rf"

# 2. Training Parameters
control$params$train <- controller_training(
  formula = target ~ .,           # Formula for Random Forest
  norm_data = TRUE,               # Use normalized data if available
  params = list(
    ntree = 100,                  # Number of trees to grow
    mtry = 3                      # Number of variables tried at each split
    # sample_weight = rep(1, N)   # Optional: vector of weights for observations
  )
)

# --- Available Parameters for train_rf ---
# formula: Formula object (e.g., target ~ .)
# norm_data: Logical, TRUE = use normalized data
# params: Named list of engine-specific settings:
#   - ntree: Integer, number of trees to grow
#   - mtry: Integer, number of variables sampled at each split
#   - sample_weight: Numeric vector of weights (optional; defaults to equal weights)

# Notes:
# - Training data is automatically injected by the workflow (do not pass via controller)
# - Engine calls randomForest::randomForest()
# - sample_weight is injected into the data inside the wrapper
# - If mtry = NULL, it is not passed to randomForest() (internal default used)
# - Execution time is returned in specific_output
