# ============================================================
# Template for Split Engine: split_random_stratified
# ============================================================

# 1. Engine Selection
control$engine_select$split <- "split_random_stratified"

# 2. Split Parameters (stratified random split)
control$params$split <- controller_split(
  seed = 123,                   # Ensures reproducibility
  target_var = "default",       # Used for stratification (must be defined)
  params = list(
    split_ratio = 0.75          # Proportion of data used for training (default = 0.7)
  )
)

# --- Available Parameters for split_random_stratified ---
# split_ratio: Numeric between 0 and 1 (e.g., 0.8 for 80% training data)
# seed: Integer (used to initialize the RNG)
#
# Notes:
# - target_var is required and used for stratification.
# - This template can be found at: inst/templates_control/template_control_split_random_stratified.R