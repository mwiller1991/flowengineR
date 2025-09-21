## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  library(flowengineR)
)

## -----------------------------------------------------------------------------
vars = controller_vars(
  feature_vars = c(
    "profession.Employee", "profession.Selfemployed", "profession.Unemployed",
    "marital_status.Divorced", "marital_status.Married", "marital_status.Single",
    "housing_status.Own", "housing_status.Rent", "housing_status.WithParents",
    "region.Rural", "region.Suburban", "region.Urban",
    "employment_length", "credit_history_length", "number_prior_loans",
    "income", "loan_amount", "credit_score", "loan_to_income"
  ),
  protected_vars = c(
    "gender.Male", "gender.Female",
    "age"
  ),
  target_var = "default",
  protected_vars_binary = c(
    "gender.Male", "gender.Female",
    "age_group.<30", "age_group.30-50", "age_group.50+"
  )
)

## -----------------------------------------------------------------------------
control <- list(
  settings = list(
    log = list(
      log_show = TRUE,
      log_level = "info"
    )
  ),
  engine_select = list(
    train = "train_lm",
    postprocessing = "postprocessing_fairness_genresidual",
    eval = c("eval_statisticalparity", "eval_mse")
    ),
  params = list(
    train = controller_training(
      formula = default ~ income + loan_amount,
      norm_data = TRUE
    ),
    postprocessing = controller_postprocessing(),
    evaluation = controller_evaluation()
  )
)

## -----------------------------------------------------------------------------
results <- run_workflow(control)

## -----------------------------------------------------------------------------
results$metrics  # all computed metrics
results$model    # trained model object

## -----------------------------------------------------------------------------
settings = list(
  log = TRUE,
  log_level = "debug"
)

