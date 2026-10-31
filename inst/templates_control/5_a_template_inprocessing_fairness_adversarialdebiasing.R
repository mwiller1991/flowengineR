# ============================================================
# Template for In-Processing Engine: inprocessing_fairness_adversarialdebiasing
# ============================================================

# 1. Engine Selection
control$engine_select$inprocessing <- "inprocessing_fairness_adversarialdebiasing"

# 2. In-Processing Parameters
control$params$inprocessing <- controller_inprocessing(
  params = list(
    learning_rate = 0.01,                       # Adversary learning rate
    num_epochs = 10,                            # Number of epochs
    num_adversary_steps = 3                     # Adversarial steps per epoch
  )
)

# --- Available Parameters for inprocessing_fairness_adversarialdebiasing ---
# learning_rate: Numeric, gradient step size for adversarial updates
# num_epochs: Integer >= 1, number of training epochs
# num_adversary_steps: Integer >= 1, adversarial updates per epoch

# Notes:
# - Training data, protected attributes and target variable are filled in
#   by the workflow (control$data$vars$protected_vars, control$data$vars$target_var)
# - Requires a training engine that uses observation weights (train_glm or
#   train_gbm); train_lm ignores them and the model stays unchanged
# - Output contains the adjusted model and the adversarial loss per epoch
