test_that("wrapper_preprocessing_fairness_resampling performs oversampling correctly", {
  # Create imbalanced dummy dataset
  set.seed(123)
  data <- data.frame(
    x1 = rnorm(100),
    x2 = rnorm(100),
    default = c(rep(0, 80), rep(1, 20))  # imbalance: 80:20
  )
  
  # Construct minimal control object
  control <- list(
    data = list(vars = list(target_var = "default")),
    params = list(
      preprocessing = controller_preprocessing(
        params = list(method = "oversampling")
      )
    )
  )
  control$params$preprocessing$data = data
  control$params$preprocessing$target_var = "default"
  
  # Run wrapper
  output <- wrapper_preprocessing_fairness_resampling(control)
  
  # Check structure of result
  expect_type(output, "list")
  expect_named(output, c("preprocessed_data", "method", "params", "specific_output"))
  expect_equal(output$method, "resampling")
  expect_s3_class(output$preprocessed_data, "data.frame")
  
  # Check if oversampling achieved class balance
  new_counts <- table(output$preprocessed_data$default)
  expect_equal(as.numeric(new_counts[1]), as.numeric(new_counts[2]))
  
  # Check specific_output contains correct structure
  expect_true(all(c("original_counts", "new_counts") %in% names(output$specific_output)))
  expect_equal(output$specific_output$original_counts$`0`, 80)
  expect_equal(output$specific_output$original_counts$`1`, 20)
  expect_equal(output$specific_output$new_counts$`0`, 80)
  expect_equal(output$specific_output$new_counts$`1`, 80)
})
