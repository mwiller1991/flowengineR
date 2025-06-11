test_that("wrapper_postprocessing_fairness_genresidual returns correctly adjusted predictions", {
  # Dummy data
  set.seed(1)
  actuals <- rnorm(100, mean = 2, sd = 1)
  predictions <- actuals + rnorm(100, mean = 0.5, sd = 0.2)  # Systematic bias
  
  # Construct control object
  control <- list(
    settings = list(output_type = "numeric"),
    data = list(vars = list(protected_vars_binary = "gender")),  # required by structure
    params = list(
      postprocessing = controller_postprocessing(
        params = list()
      )
    )
  )
  control$params$postprocessing$postprocessing_data = list(
    predictions = predictions,
    actuals = actuals
  )
  control$params$postprocessing$protected_name = "gender"
  
  # Run wrapper
  output <- wrapper_postprocessing_fairness_genresidual(control)
  
  # Check output structure
  expect_type(output, "list")
  expect_named(output, c("adjusted_predictions", "method", "input_data", "protected_attributes", "params"))
  expect_equal(output$method, "general_residual")
  expect_type(output$adjusted_predictions, "double")
  expect_length(output$adjusted_predictions, length(actuals))
  
  # Check mean adjustment effect
  residuals <- actuals - predictions
  expected_adjustment <- mean(residuals)
  expect_equal(output$adjusted_predictions, predictions + expected_adjustment, tolerance = 1e-6)
})
