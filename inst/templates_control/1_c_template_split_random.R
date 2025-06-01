# ============================================================
# Template for Split Engine: split_random
# ============================================================

# 1. Engine Selection
control$split_method <- "split_random"

# 2. Split Parameters (random, non-stratified split)
control$params$split <- controller_split(
  seed = 123,                  # Ensures reproducibility
  target_var = "default",      # Required by framework, ignored by this engine
  params = list(
    split_ratio = 0.7          # Proportion of data used for training (default = 0.7)
  )
)

# --- Available Parameters for split_random ---
# split_ratio: Numeric between 0 and 1 (e.g., 0.6 for 60% training data)
# seed: Integer (used to initialize the RNG)
#
# Notes:
# - target_var is required for framework compatibility, but not used by this engine.
# - No stratification is applied. For stratified splitting, use "split_random_stratified".
# - This template can be found at: inst/templates/template_control_split_random.R