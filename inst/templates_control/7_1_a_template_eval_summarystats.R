# ============================================================
# Template for Evaluation Engine: eval_summarystats
# ============================================================

# 1. Engine Selection
control$engine_select$evaluation <- "eval_summarystats"

# 2. Evaluation Parameters
control$params$evaluation <- controller_evaluation(
  protected_name = c("gender")    # Only tracked; not used for metric calculation
  # params = list()               # Not required for this engine
)

# --- Available Parameters for eval_summarystats ---
# protected_name: Character vector (for tracking only)
# params: Not used (NULL)

# Notes:
# - Predictions are automatically injected by the workflow
# - The engine computes summary statistics:
#     mean, median, sd, var, min, max, 25%-quantile, 75%-quantile, IQR, skewness, kurtosis, range
# - Output is accessible under metrics$summary_stats