# controller_training(): the formula can be left out and is built from control$data$vars

make_training_control <- function(train_controller) {
  my_vars <- controller_vars(
    feature_vars = c("income", "loan_amount"),
    protected_vars = "gender.Female",
    target_var = "default",
    protected_vars_binary = c("gender.Female", "gender.Male")
  )
  list(
    settings = list(log = list(log_show = FALSE)),
    data = list(vars = my_vars, full = test_data_2_base_credit_example),
    engine_select = list(train = "train_lm", evaluation = "eval_mse"),
    params = list(train = train_controller)
  )
}

trained_formula <- function(result) {
  deparse(formula(result$execution_output$workflow_results[[1]]$output_train$model))
}

test_that("controller_training() needs no object 'vars' and leaves the formula open", {
  expect_null(controller_training()$formula)
})

test_that("without a formula, run_workflow() builds it from control$data$vars", {
  res <- run_workflow(make_training_control(controller_training()))
  expect_identical(trained_formula(res), "default ~ income + loan_amount + gender.Female")
})

test_that("an explicitly given formula is used unchanged", {
  res <- run_workflow(make_training_control(controller_training(formula = default ~ income)))
  expect_identical(trained_formula(res), "default ~ income")
})
