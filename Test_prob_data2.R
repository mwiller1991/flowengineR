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
source("~/fairness_toolbox/R/engines/fairness/pre-processing/initialize_output_fairness_pre.R")
source("~/fairness_toolbox/R/engines/training/initialize_output_train.R")
source("~/fairness_toolbox/R/engines/fairness/in-processing/initialize_output_fairness_in.R")
source("~/fairness_toolbox/R/engines/fairness/post-processing/initialize_output_fairness_post.R")
source("~/fairness_toolbox/R/engines/evaluation/initialize_output_eval.R")

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
    full = dataset,    # Optional, falls Daten nicht getrennt übergeben werden
    train = NULL,      # Training data
    test = NULL        # Test data
  ),
  split_method = "split_random",   # Method for splitting (e.g., "split_random" or "split_cv")
  train_model = "train_glm",
  output_type = "response", # Add option for output type ("response" or "prob") depends on model (GLM/LM do not support prob)
  fairness_pre = NULL, #"fairness_pre_resampling",
  fairness_in = "fairness_in_adversialdebiasing",
  fairness_post = NULL, #"fairness_post_genresidual",
  evaluation = list("eval_mse", "eval_summarystats"), #list("eval_summarystats", "eval_mse", "eval_statisticalparity")
  params = list(
    split = controller_split(
      split_ratio = 0.7,
      cv_folds = 5,
      seed = 123
    ),
    fairness_pre = controller_fairness_pre(
      protected_attributes = vars$protected_vars,
      target_var = vars$target_var,
      params =   list(
        method = "undersampling"
      )
    ),
    train = controller_training(
      formula = as.formula(paste(vars$target_var, "~", paste(vars$feature_vars, collapse = "+"), "+", paste(vars$protected_vars, collapse = "+")))
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
    )
  )
)


# Run the Workflow
result <- run_workflow(control)

# Output-Funktionen -> das werden mal Reporting-Engines
# Funktion zur strukturierten Anzeige der Split-Engine-Ergebnisse
print_split_results <- function(result) {
  cat("\n=== Split-Engine Ergebnisse ===\n")
  
  # Anzeige der Splits
  if (!is.null(result$splits)) {
    cat("\n== Datenaufteilung ==\n")
    cat("Trainingsdaten:", nrow(result$splits$random_split$train), "Zeilen\n")
    cat("Testdaten:", nrow(result$splits$random_split$test), "Zeilen\n")
  }
  
  # Anzeige der Workflow-Ergebnisse
  if (!is.null(result$workflow_results)) {
    cat("\n== Workflow-Ergebnisse pro Split ==\n")
    for (split_name in names(result$workflow_results)) {
      cat("\n=== Ergebnisse für Split:", split_name, "===\n")
      split_result <- result$workflow_results[[split_name]]
      print_workflow_results(split_result)
    }
  }
  
  # Anzeige der aggregierten Ergebnisse
  if (!is.null(result$aggregated_results)) {
    cat("\n== Aggregierte Ergebnisse ==\n")
    print(result$aggregated_results)
  }
  
  cat("\n=========================================\n")
}


print_workflow_results <- function(result) {
  if (!is.null(result$output_train)) {
    cat("\n== Trainingsergebnisse ==\n")
    cat("Modelltyp:", result$output_train$model_type, "\n")
    cat("Formel:", deparse(result$output_train$formula), "\n")
    if (!is.null(result$output_train$hyperparameters)) {
      cat("Hyperparameter:\n")
      print(result$output_train$hyperparameters)
    }
    cat("Trainingszeit:", result$output_train$training_time, "Sekunden\n")
    cat("Beispiel Vorhersagen:\n")
    print(head(result$output_train$predictions))
  }
  
  if (!is.null(result$output_fairness_post)) {
    cat("\n== Fairness Post-Processing ==\n")
    cat("Methode:", result$output_fairness_post$method, "\n")
    cat("Beispiel angepasste Vorhersagen:\n")
    print(head(result$output_fairness_post$adjusted_predictions))
  }
  
  if (!is.null(result$output_eval)) {
    cat("\n== Evaluationsergebnisse ==\n")
    for (metric_name in names(result$output_eval)) {
      cat("Metrik:", metric_name, "\n")
      print(result$output_eval[[metric_name]]$metrics)
    }
  }
}


# Beispiel: Ergebnisse ausgeben
print_split_results(result)




# Run the full 3x Workflow
result_full <- run_workflow_variants(control)

# Output Results
#noch offen