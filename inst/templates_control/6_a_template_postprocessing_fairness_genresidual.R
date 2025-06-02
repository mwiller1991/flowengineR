# ============================================================
# Template for Post-Processing Engine: postprocessing_fairness_genresidual
# ============================================================

# 1. Engine Selection
control$postprocessing <- "postprocessing_fairness_genresidual"

# 2. Post-Processing Parameters
control$params$postprocessing <- controller_postprocessing(
  protected_name = c("gender")   # Names of protected variables (for tracking only)
  # params = list()              # Not required; this engine has no tunable parameters
)

# --- Available Parameters for postprocessing_fairness_genresidual ---
# protected_name: Character vector of protected attributes
# params: Optional list (unused by this engine)

# Notes:
# - predictions and actuals are provided automatically by the workflow
# - the engine applies the mean residual (actual - predicted) to all predictions
# - output remains within [0, 1] if output_type == "prob"