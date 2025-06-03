# ============================================================
# Template for Evaluation Engine: eval_mse
# ============================================================

# 1. Engine Selection
control$engine_select$evaluation <- "eval_mse"

# 2. Evaluation Parameters
control$params$eval <- controller_evaluation(
  protected_name = c("gender")    # Optional; included in output
  # params = list(eval_mse = list())  # Not required; engine uses no parameters
)

# --- Available Parameters for eval_mse ---
# predictions: Automatically provided by workflow
# actuals: Automatically provided by workflow
# protected_name: Optional; passed through in result
# params: Not used (can be empty list)

# Notes:
# - Computes mean squared error between predictions and actuals
# - Output is a single value under metrics$mse