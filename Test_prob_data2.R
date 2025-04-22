# Load required libraries
library(ggplot2)
library(caret)
library(magrittr)
library(moments)
library(dplyr)


# Load the Controller Functions
source("~/fairness_toolbox/R/metalevel/metalevel.R")

# Load the helper Functions
source("~/fairness_toolbox/R/metalevel/helper.R")

# Load the initiate output Functions
source("~/fairness_toolbox/R/engines/split/initialize_output_split.R")
source("~/fairness_toolbox/R/engines/fairness/pre-processing/initialize_output_fairness_pre.R")
source("~/fairness_toolbox/R/engines/training/initialize_output_train.R")
source("~/fairness_toolbox/R/engines/fairness/in-processing/initialize_output_fairness_in.R")
source("~/fairness_toolbox/R/engines/fairness/post-processing/initialize_output_fairness_post.R")
source("~/fairness_toolbox/R/engines/evaluation/initialize_output_eval.R")
source("~/fairness_toolbox/R/engines/reporting/initialize_output_reportelement.R")

# Load the Controller Functions
source("~/fairness_toolbox/R/controller/controller_1_inputR.R")

# Load the Engine Registry
source("~/fairness_toolbox/R/metalevel/registry.R")

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
  protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")            # Protected variables for evaluations (in groups)
)

# Control Object for Prototyping
control <- list(
  global_seed = 1,
  vars = vars,         # Include vars within control for consistency
  data = list(
    full = dataset,    # Optional, if splitter engine is used
    train = NULL,      # Training data
    test = NULL        # Test data
  ),
  split_method = "split_cv",   # Method for splitting (e.g., "split_random" or "split_cv")
  train_model = "train_lm",
  output_type = "response", # Add option for output type ("response" or "prob") depends on model (GLM/LM do not support prob)
  fairness_pre = NULL, #"fairness_pre_resampling",
  fairness_in = NULL, #"fairness_in_adversialdebiasing",
  fairness_post = "fairness_post_genresidual",
  evaluation = list("eval_mse", "eval_summarystats", "eval_statisticalparity"), #list("eval_summarystats", "eval_mse", "eval_statisticalparity")
  reportelement = list(
    gender_box_raw = "reportelement_boxplot_predictions",
    gender_box_adjusted = "reportelement_boxplot_predictions",
    age_box = "reportelement_boxplot_predictions",
    metrics_table = "reportelement_table_splitmetrics"
  ),
  params = list(
    split = controller_split(
      seed = 123,
      target_var = vars$target_var,
      params =   list(cv_folds = 6
      )
    ),
    fairness_pre = controller_fairness_pre(
      protected_attributes = vars$protected_vars,
      target_var = vars$target_var,
      params =   list(
        method = "undersampling"
      )
    ),
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+"))),
      norm_data = TRUE
    ),
    fairness_in = controller_fairness_in(
      protected_attributes = vars$protected_vars,
      target_var = vars$target_var,
      params =   list(
        learning_rate = 0.1,
        num_epochs = 1000,
        num_adversary_steps = 10
      )
    ),
    fairness_post = controller_fairness_post(
      protected_name = vars$protected_vars_binary
    ),
    eval = controller_evaluation(
      protected_name = vars$protected_vars_binary,
      params = list(
        eval_mse = list(weighting_factor = 0.5), #Example for Test
        eval_statisticalparity = list(threshold = 0.1) #Example for Test
      )
    ),
    reportelement = controller_reportelement(
      params = list(
        gender_box_raw = list(group_var = "genderMale", source = "train"),
        gender_box_adjusted = list(group_var = "genderMale", source = "post"),
        age_box = list(group_var = "age_group.50+"),
        metrics_table = list(metrics = c("mse", "statisticalparity", "summarystats"))
      )
    )
  )
)


# Run the Workflow
result <- fairness_workflow(control)
result$reportelements$metrics_table$content
result$reportelements$gender_box_raw$content
View(result$reportelements$metrics_table$content)

result_full <- fairness_workflow_variants(control)
