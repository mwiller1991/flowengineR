# ============================================================
# Template for Training Engine: train_gbm
# ============================================================

# 1) Engine Selection
control$engine_select$train <- "train_gbm"

# 2) Training Parameters
control$params$train <- controller_training(
  formula   = target ~ .,   # Model formula
  norm_data = TRUE,         # Use normalized data if provided by the workflow
  params = list(
    # ---- Core GBM hyperparameters ----
    distribution      = NULL,   # If NULL: auto-infer ("bernoulli" for binary target, else "gaussian")
    n.trees           = 1000,   # Number of boosting iterations
    interaction.depth = 3,      # Tree depth
    shrinkage         = 0.05,   # Learning rate
    n.minobsinnode    = 10,     # Min. obs. in terminal node
    bag.fraction      = 0.5,    # Subsample fraction per tree
    train.fraction    = 1.0,    # Fraction of rows used for training within gbm (rest for internal eval)
    
    # ---- Optional: observation weights ----
    # sample_weight = rep(1, N)  # If NULL, wrapper uses equal weights
  )
)

# --- Available Parameters for train_gbm ---
# formula:     Formula object (e.g., target ~ .)
# norm_data:   Logical; TRUE = use normalized data (if available)
# params:      Named list of engine-specific settings:
#   - distribution:       "gaussian" or "bernoulli"; if NULL, wrapper infers from response
#   - n.trees:            Integer, number of boosting iterations
#   - interaction.depth:  Integer, tree depth
#   - shrinkage:          Numeric, learning rate
#   - n.minobsinnode:     Integer, min. obs. per terminal node
#   - bag.fraction:       Numeric in (0,1], subsample fraction per tree
#   - train.fraction:     Numeric in (0,1], rows used for fitting inside gbm
#   - sample_weight:      Numeric vector of observation weights (optional)

# Notes:
# - Training data is injected by the workflow; do not pass data here.
# - Engine calls gbm::gbm() via engine_train_gbm().
# - For classification (bernoulli): wrapper ensures a 0/1-coded target and stores the level→{0,1} mapping
#   in specific_output$class_mapping.
# - For regression: default distribution is "gaussian".
# - sample_weight is added to the data by the wrapper before calling the engine.
# - Execution time is returned in specific_output$training_time.

# --- Example variants ---

# (A) Binary classification with explicit distribution
# control$params$train$params$distribution <- "bernoulli"

# (B) Regression with explicit settings
# control$params$train$params <- modifyList(
#   control$params$train$params,
#   list(
#     distribution      = "gaussian",
#     n.trees           = 1500,
#     interaction.depth = 4,
#     shrinkage         = 0.03,
#     bag.fraction      = 0.7
#   )
# )
