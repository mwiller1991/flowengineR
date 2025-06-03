# ============================================================
# Template for In-Processing Engine: inprocessing_fairness_adversialdebiasing
# ============================================================

# 1. Engine Selection
control$engine_select$inprocessing <- "inprocessing_fairness_adversialdebiasing"

# 2. In-Processing Parameters
control$params$inprocessing <- controller_inprocessing(
  protected_attributes = c("gender", "race"),   # Names of sensitive variables
  target_var = "outcome",                       # Variable to be predicted
  params = list(
    learning_rate = 0.01,                       # Adversary learning rate
    num_epochs = 10,                            # Number of epochs
    num_adversary_steps = 3                     # Adversarial steps per epoch
  )
)

# --- Available Parameters for inprocessing_fairness_adversialdebiasing ---
# protected_attributes: Character vector, e.g., c("gender", "race")
# target_var: String, name of the target variable
# learning_rate: Numeric, gradient step size for adversarial updates
# num_epochs: Integer ≥ 1, number of training epochs
# num_adversary_steps: Integer ≥ 1, adversarial updates per epoch

# Notes:
# - Data is automatically provided by the workflow
# - Engine expects a compatible training engine (`driver_train`) to be passed
# - Output contains adjusted model and detailed adversarial loss