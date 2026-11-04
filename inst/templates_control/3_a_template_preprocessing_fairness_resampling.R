# ============================================================
# Template for Pre-Processing Engine: preprocessing_fairness_resampling
# ============================================================

# 1. Engine Selection
control$engine_select$preprocessing <- "preprocessing_fairness_resampling"

# 2. Pre-Processing Parameters
control$params$preprocessing <- controller_preprocessing(
  params = list(
    method = "oversampling"                # Options: "oversampling" or "undersampling"
  )
)

# --- Available Parameters for preprocessing_fairness_resampling ---
# method: "oversampling" or "undersampling"

# Notes:
# - Training data, target variable and protected attributes are filled in
#   by the workflow (control$data$train and control$data$vars)
# - Method balances binary target classes
# - Output includes resampled data and distribution info
# - Protected attributes are ignored by this engine
