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
dataset <- create_dataset_1(seed = 1)

#Variablen
vars = list(
  feature_vars = c("income", "profession.Employee", "profession.Self-employed"),  # All non-protected variables
  protected_vars = c("gender.Female", "gender.Male", "age"),            # Protected variables
  target_var = "damage",                            # Target variable
  protected_vars_eval = c("gender.Female", "gender.Male", "age_group.<40", "age_group.40-60", "age_group.60+")            # Protected variables for evaluations (in groups)
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
      data = data
    ),
    fairness = controller_fairness_post(
      predictions = NULL,
      actuals = data[[vars$target_var]]
    ),
    eval = controller_evaluation(
      predictions = NULL,
      actuals = data[[vars$target_var]],
      protected_attribute = data[vars$protected_vars_eval],
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
