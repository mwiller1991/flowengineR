## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  library(flowengineR)
)

## -----------------------------------------------------------------------------
vars = controller_vars(
  feature_vars = c("income", "loan_amount", "credit_score", "professionEmployee", "professionSelfemployed", "professionUnemployed"),
  protected_vars = c("genderFemale", "genderMale", "age"),   
  target_var = "default",            
  protected_vars_binary = c("genderFemale", "genderMale", "age_group.<30", "age_group.30-50", "age_group.50+")
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
    eval = controller_evaluation()
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

