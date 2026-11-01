# ============================================================
# Template for Evaluation Engine: eval_mse
# ============================================================

# 1. Engine Selection
control$engine_select$evaluation <- "eval_mse"

# 2. Evaluation Parameters
control$params$evaluation <- controller_evaluation(
  params = list()                # Not required; engine uses no parameters
)

# --- Available Parameters for eval_mse ---
# None. Predictions and actuals are provided automatically by the workflow.

# Notes:
# - Computes mean squared error between predictions and actuals
# - Output is a single value under metrics$mse
