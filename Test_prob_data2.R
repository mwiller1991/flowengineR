# Load required libraries
library(ggplot2)
library(caret)
library(magrittr)


# Load the Controller Functions
source("~/fairness_toolbox/R/metalevel/metalevel.R")

# Load the Engine Registry
source("~/fairness_toolbox/R/metalevel/registry.R")

# Load the Controller Functions
source("~/fairness_toolbox/R/controller/controller_1_inputR.R")

# Load the data
source("~/fairness_toolbox/data/data_generation.R")

# Load the memory-size-logger
source("~/fairness_toolbox/tests/memory_logging_dev.R")

# Generate the dataset
dataset <- create_dataset_2(seed = 1)

#Setting variables fitting to the dataset
vars = list(
  feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"),  # All non-protected variables
  protected_vars = c("genderFemale", "genderMale", "age"),            # Protected variables
  target_var = "default",                            # Target variable
  protected_vars_eval = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")            # Protected variables for evaluations (in groups)
)

# Control Object for Prototyping
control <- list(
  global_seed = 1,
  vars = vars,         # Include vars within control for consistency
  data = list(
    full = dataset,    # Optional, falls Daten nicht getrennt übergeben werden
    train = NULL,      # Training data
    test = NULL        # Test data
  ),
  split_method = "split_cv",   # Method for splitting (e.g., "split_random" or "split_cv")
  train_model = "train_lm",
  output_type = "prob", # Add option for output type ("prob" or "class")
  fairness_pre = NULL,
  fairness_in = NULL,
  fairness_post = "fairness_post_genresidual",
  evaluation = list("eval_mse", "eval_statisticalparity"),
  params = list(
    split = controller_split(
      split_ratio = 0.7,
      cv_folds = 5,
      seed = 123
    ),
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
      data = NULL
    ),
    fairness = controller_fairness_post(
      predictions = NULL,
      actuals = NULL
    ),
    eval = controller_evaluation(
      eval_data = NULL,
      protected_name = vars$protected_vars_eval
    )
  )
)


# Run the Workflow
result <- run_workflow(control)

# Output Results
print(result$model)
print(head(result$predictions))
print(result$evaluation)


# Run the full 3x Workflow
result_full <- run_workflow_variants(control)

# Output Results
print(result_full$discriminationfree$model)
print(result_full$bestestimate$model)
print(result_full$unawareness$model)
print(head(result_full$discriminationfree$predictions))
print(head(result_full$bestestimate$predictions))
print(head(result_full$unawareness$predictions))
print(result_full$discriminationfree$evaluation)
print(result_full$bestestimate$evaluation)
print(result_full$unawareness$evaluation)