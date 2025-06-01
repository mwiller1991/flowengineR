# ============================================================
# Template for Fairness Pre-Processing Engine: fairness_pre_resampling
# ============================================================

# 1. Engine Selection
control$fairness_pre <- "fairness_pre_resampling"

# 2. Pre-Processing Parameters
control$params$fairness_pre <- controller_fairness_pre(
  data = training_data,                    # Data to be resampled
  target_var = "outcome",                  # Target variable to balance
  protected_attributes = c("gender"),      # Not used here, but required for compatibility
  params = list(
    method = "oversampling"                # Options: "oversampling" or "undersampling"
  )
)

# --- Available Parameters for fairness_pre_resampling ---
# method: "oversampling" or "undersampling"
# data, target_var, protected_attributes: Passed automatically by workflow

# Notes:
# - Method balances binary target classes
# - Output includes resampled data and distribution info
# - Protected attributes are ignored by this engine