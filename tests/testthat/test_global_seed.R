# settings$global_seed makes workflows reproducible that have no seed of their own

make_seed_control <- function(global_seed) {
  d <- test_data_2_base_credit_example
  is_test <- seq_len(nrow(d)) %% 4 == 0
  list(
    settings = list(log = list(log_show = FALSE), global_seed = global_seed),
    data = list(
      vars = controller_vars(
        feature_vars = c("income", "loan_amount", "credit_score"),
        protected_vars = "gender.Female",
        target_var = "default",
        protected_vars_binary = c("gender.Female", "gender.Male")
      ),
      full = d, train = d[!is_test, ], test = d[is_test, ]
    ),
    engine_select = list(split = "split_userdefined", train = "train_gbm", evaluation = "eval_mse"),
    params = list(
      train = controller_training(
        formula = default ~ income + loan_amount + credit_score,
        params = list(n.trees = 50, distribution = "gaussian")
      )
    )
  )
}
mse_of <- function(control) {
  suppressMessages(run_workflow(control))$aggregated_results$mse$mean
}

test_that("global_seed makes a workflow without its own seed reproducible", {
  set.seed(10)
  a <- mse_of(make_seed_control(1))
  set.seed(20)
  b <- mse_of(make_seed_control(1))
  expect_identical(a, b)
  expect_false(identical(a, mse_of(make_seed_control(2))))
})

test_that("run_workflow() leaves the random number state of the session unchanged", {
  set.seed(5)
  before <- .Random.seed
  invisible(mse_of(make_seed_control(1)))
  expect_identical(.Random.seed, before)
})
