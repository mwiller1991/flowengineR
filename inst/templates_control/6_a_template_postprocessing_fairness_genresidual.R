# ============================================================
# Template for Post-Processing Engine: postprocessing_fairness_genresidual
# ============================================================

# 1. Engine Selection
control$engine_select$postprocessing <- "postprocessing_fairness_genresidual"

# 2. Post-Processing Parameters
control$params$postprocessing <- controller_postprocessing(
  params = list()                # Not required; this engine has no tunable parameters
)

# --- Available Parameters for postprocessing_fairness_genresidual ---
# None.

# Notes:
# - predictions, actuals and the binary protected attributes are provided
#   automatically by the workflow (control$data$vars$protected_vars_binary)
# - the engine applies the mean residual (actual - predicted) to all predictions
# - output remains within [0, 1] if output_type == "prob"
