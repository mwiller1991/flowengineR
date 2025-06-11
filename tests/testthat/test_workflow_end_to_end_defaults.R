test_that("run_workflow executes a full end-to-end workflow without error", {

  # Dummy Seed
  set.seed(42)
  
  # Construct control object
  control <- list(
    settings = list(
      log = list(
        log_show = FALSE
      ),
      output_type = "response"
    )
  )
  
  # Run the full workflow
  result <- run_workflow(control)
  
  # Extract split names
  split_names <- names(result$split_output$splits)
  workflow_names <- names(result$execution_output$workflow_results)
  
  
  
  ## Tests
  # Check: both are named and have the same length
  expect_type(split_names, "character")
  expect_type(workflow_names, "character")
  expect_length(workflow_names, length(split_names))
  
  # Check: names must match exactly
  expect_setequal(workflow_names, split_names)
  
  # High-level output check
  expect_type(result, "list")
  expect_named(result, c("split_output", "execution_output", "aggregated_results", "reportelements", "reports", "publishing"))
  
  # Detailed structure checks
  expect_true("splits" %in% names(result$split_output))
  expect_true("workflow_results" %in% names(result$execution_output))
  expect_type(result$aggregated_results, "list")
  
})
