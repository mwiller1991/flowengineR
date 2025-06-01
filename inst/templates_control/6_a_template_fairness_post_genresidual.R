# ============================================================
# Template for Fairness Post-Processing Engine: fairness_post_genresidual
# ============================================================

# 1. Engine Selection
control$fairness_post <- "fairness_post_genresidual"

# 2. Post-Processing Parameters
control$params$fairness_post <- controller_fairness_post(
  protected_name = c("gender")   # Names of protected variables (for tracking only)
  # params = list()              # Not required; this engine has no tunable parameters
)

# --- Available Parameters for fairness_post_genresidual ---
# protected_name: Character vector of protected attributes
# params: Optional list (unused by this engine)

# Notes:
# - predictions and actuals are provided automatically by the workflow
# - the engine applies the mean residual (actual - predicted) to all predictions
# - output remains within [0, 1] if output_type == "prob"