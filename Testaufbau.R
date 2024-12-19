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

# Generate the dataset
dataset <- create_dataset_1(seed = 2)

#Setting variables fitting to the dataset
vars = list(
  feature_vars = c("income", "professionEmployee", "professionSelfemployed"),  # All non-protected variables
  protected_vars = c("genderFemale", "genderMale", "age"),            # Protected variables
  target_var = "damage",                            # Target variable
  protected_vars_eval = c("genderFemale", "genderMale", "age_group.<40", "age_group.40-60", "age_group.60+")            # Protected variables for evaluations (in groups)
)

# Control Object for Prototyping
control <- list(
  model = "train_lm",
  fairness_pre = NULL,
  fairness_in = NULL,
  fairness_post = "fairness_post_residual",
  evaluation = list("eval_mse", "eval_statisticalparity"),
  params = list(
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
      data = dataset
    ),
    fairness = controller_fairness_post(
      predictions = NULL,
      actuals = dataset[[vars$target_var]]
    ),
    eval = controller_evaluation(
      predictions = NULL,
      actuals = dataset[[vars$target_var]],
      protected_attribute = dataset[vars$protected_vars_eval],
      protected_name = vars$protected_vars_eval
    )
  )
)


# Run the Workflow
result <- run_workflow(control)

# Output Results
print(result$model)
print(head(result$predictions))
print(head(result$adjusted_predictions))
print(result$evaluation)
