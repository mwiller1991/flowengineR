test_that("wrapper_eval_mse returns correct MSE in standardized format", {
  # Dummy predictions and actuals
  set.seed(42)
  actuals <- rnorm(100, mean = 1)
  predictions <- actuals + rnorm(100, mean = 0.1, sd = 0.5)
  
  # Manual MSE for comparison
  expected_mse <- mean((predictions - actuals)^2)
  
  # Construct control object
  control <- list(
    settings = list(log = list(log_show = FALSE)),
    params = list(
      evaluation = list(
        params = list()  # No specific parameters needed
      )
    )
  )

control$params$evaluation$eval_data = list(
    predictions = predictions,
    actuals = actuals
)
control$params$evaluation$eval_protected_attributes = c("gender")

  
  # Run wrapper
  output <- wrapper_eval_mse(control)
  
  # Structural tests
  expect_type(output, "list")
  expect_named(output, c("metrics", "eval_type", "input_data", "params"))
  expect_equal(output$eval_type, "mse_eval")
  
  # Metric correctness
  expect_true("mse" %in% names(output$metrics))
  expect_equal(output$metrics$mse, expected_mse, tolerance = 1e-6)
})
