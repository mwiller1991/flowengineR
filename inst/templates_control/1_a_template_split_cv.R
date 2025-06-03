# ============================================================
# Template for Split Engine: split_cv
# ============================================================

# 1. Engine Selection
control$engine_select$split <- "split_cv"

# 2. Split Parameters (stratified cross-validation)
control$params$split <- controller_split(
  seed = 42,                    # Ensures reproducibility
  target_var = "default",       # Used for stratification across folds
  params = list(
    cv_folds = 5                # Number of folds (default = 5)
  )
)

# --- Available Parameters for split_cv ---
# cv_folds: Integer > 1 (e.g., 5 for 5-fold CV)
# seed: Integer (used to initialize the RNG)
#
# Notes:
# - target_var is required and used for stratified fold creation.
# - At least 2 folds must be specified.
# - This template can be found at: inst/templates_control/template_control_split_cv.R