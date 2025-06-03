# ============================================================
# Template for Pre-Processing Engine: preprocessing_fairness_resampling
# ============================================================

# 1. Engine Selection
control$engine_select$preprocessing <- "preprocessing_fairness_resampling"

# 2. Pre-Processing Parameters
control$params$preprocessing <- controller_preprocessing(
  data = training_data,                    # Data to be resampled
  target_var = "outcome",                  # Target variable to balance
  protected_attributes = c("gender"),      # Not used here, but required for compatibility
  params = list(
    method = "oversampling"                # Options: "oversampling" or "undersampling"
  )
)

# --- Available Parameters for preprocessing_fairness_resampling ---
# method: "oversampling" or "undersampling"
# data, target_var, protected_attributes: Passed automatically by workflow

# Notes:
# - Method balances binary target classes
# - Output includes resampled data and distribution info
# - Protected attributes are ignored by this engine