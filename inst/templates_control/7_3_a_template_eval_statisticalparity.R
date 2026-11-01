# ============================================================
# Template for Evaluation Engine: eval_statisticalparity
# ============================================================

# 1. Engine Selection
control$engine_select$evaluation <- "eval_statisticalparity"

# 2. Evaluation Parameters
control$params$evaluation <- controller_evaluation(
  params = list()                # Not required
)

# --- Available Parameters for eval_statisticalparity ---
# None. Predictions and the binary protected attributes are provided
# automatically by the workflow (control$data$vars$protected_vars_binary).

# Notes:
# - Only binary protected attributes are supported
# - SPD = | mean(pred | group A) - mean(pred | group B) |
# - Output is named list in metrics$spd
