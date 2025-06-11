test_that("wrapper_train_glm trains a GLM and returns standardized output", {
  # Dummy dataset
  set.seed(1)
  data <- data.frame(
    y = rnorm(100),
    x1 = rnorm(100),
    x2 = rnorm(100)
  )
  
  # Construct minimal control object
  control <- list(
    params = list(
      train = controller_training(
        formula = y ~ x1 + x2,
        norm_data = FALSE,
        params = list(family = gaussian())  # use default explicitly
      )
    )
  )
  control$params$train$data = list(original = data, normalized = data)
  
  # Run wrapper
  output <- wrapper_train_glm(control)
  
  # Check output structure
  expect_type(output, "list")
  expect_named(output, c("model", "model_type", "formula", "predictions", "hyperparameters", "specific_output"))
  expect_equal(output$model_type, "glm")
  expect_s3_class(output$model, "glm")
  expect_true(inherits(output$formula, "formula"))
  
  # Check that default weight was applied correctly (optional)
  expect_equal(output$hyperparameters$sample_weight, rep(1, nrow(data)))
})