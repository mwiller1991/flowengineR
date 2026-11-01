# ============================================================
# Template for Evaluation Engine: eval_summarystats
# ============================================================

# 1. Engine Selection
control$engine_select$evaluation <- "eval_summarystats"

# 2. Evaluation Parameters
control$params$evaluation <- controller_evaluation(
  params = list()                # Not required for this engine
)

# --- Available Parameters for eval_summarystats ---
# None. Predictions are provided automatically by the workflow.

# Notes:
# - The engine computes summary statistics:
#     mean, median, sd, var, min, max, 25%-quantile, 75%-quantile, IQR, skewness, kurtosis, range
# - Output is accessible under metrics$summary_stats
