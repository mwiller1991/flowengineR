# ============================================================
# Template for Training Engine: train_glm
# ============================================================

# 1. Engine Selection
control$engine_select$train <- "train_glm"

# 2. Training Parameters
control$params$train <- controller_training(
  formula = target ~ .,           # Formula for GLM
  norm_data = TRUE,               # Use normalized data if available
  params = list(
    family = gaussian()           # Default family (can be changed to e.g., binomial())
    # sample_weight = rep(1, N)   # Optional: vector of weights for observations
  )
)

# --- Available Parameters for train_glm ---
# formula: Formula object (e.g., target ~ .)
# norm_data: Logical, TRUE = use normalized data
# params: Named list of engine-specific settings:
#   - family: GLM family (e.g., gaussian(), binomial(), poisson(), etc.)
#   - sample_weight: Numeric vector of weights (optional; defaults to equal weights)

# Notes:
# - Training data is automatically injected by the workflow (do not pass via controller)
# - Engine calls stats::glm()
# - sample_weight is injected into the data inside the wrapper
# - Execution time is returned in specific_output