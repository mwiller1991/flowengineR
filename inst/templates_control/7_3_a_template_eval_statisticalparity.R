# ============================================================
# Template for Evaluation Engine: eval_statisticalparity
# ============================================================

# 1. Engine Selection
control$engine_select$evaluation <- "eval_statisticalparity"

# 2. Evaluation Parameters
control$params$evaluation <- controller_evaluation(
  protected_name = c("gender", "race")   # Binary protected attributes only
  # params = list()                      # Not required
)

# --- Available Parameters for eval_statisticalparity ---
# protected_name: Character vector of protected attribute names
# eval_data: Automatically provided by workflow (must include predictions and protected attributes)
# params: Not used

# Notes:
# - Only binary protected attributes are supported
# - SPD = | mean(pred | group A) - mean(pred | group B) |
# - Output is named list in metrics$spd