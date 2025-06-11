test_that("wrapper_split_cv returns valid cross-validation splits", {
  # Create dummy data with a binary target variable
  set.seed(123)
  data <- data.frame(
    x1 = rnorm(100),
    x2 = rnorm(100),
    default = sample(c(0, 1), 100, replace = TRUE)
  )
  
  # Construct minimal control input
  control <- list(
    data = list(full = data),
    params = list(
      split = controller_split(
        seed = 42,
        params = list(cv_folds = 5)
      )
    )
  )
  control$params$split$target_var = "default"
  
  # Run wrapper
  output <- wrapper_split_cv(control)
  
  # Basic structure checks
  expect_type(output, "list")
  expect_named(output, c("split_type", "splits", "seed", "params", "specific_output"))
  expect_equal(output$split_type, "cv")
  expect_equal(output$seed, 42)
  expect_equal(length(output$splits), 5)
  
  # Each fold must contain train and test sets as data frames
  for (fold in output$splits) {
    expect_true(all(c("train", "test") %in% names(fold)))
    expect_s3_class(fold$train, "data.frame")
    expect_s3_class(fold$test, "data.frame")
  }
  
  # Check stratification: target variable distribution should be roughly equal
  full_proportion <- mean(data$default)
  fold_proportions <- sapply(output$splits, function(fold) mean(fold$test$default))
  expect_true(all(abs(fold_proportions - full_proportion) < 0.15))  # allow small deviation
})