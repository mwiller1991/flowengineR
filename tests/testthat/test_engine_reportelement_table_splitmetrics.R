test_that("wrapper_reportelement_table_splitmetrics returns correct metric table", {
  # Simulate workflow results for 3 splits with MSE metrics
  workflow_results <- list(
    split1 = list(output_eval = list(eval_mse = list(metrics = list(mse = 0.1)))),
    split2 = list(output_eval = list(eval_mse = list(metrics = list(mse = 0.2)))),
    split3 = list(output_eval = list(eval_mse = list(metrics = list(mse = 0.3))))
  )
  
  # Minimal control object
  control <- list(
    settings = list(log = list(log_show = FALSE)),
    params = list(
      reportelement = controller_reportelement(
        params = list(split_table = list(metrics = c("mse")))
      )
    )
  )
  
  # Run wrapper
  output <- wrapper_reportelement_table_splitmetrics(
    control = control,
    workflow_results = workflow_results,
    split_output = NULL,
    alias = "split_table"
  )
  
  # Check standardized structure
  expect_type(output, "list")
  expect_named(output, c("type", "content", "compatible_formats", "input_data", "params", "specific_output"))
  expect_equal(output$type, "table")
  expect_s3_class(output$content, "data.frame")
  expect_equal(nrow(output$content), 3)
  expect_true("mse_mse" %in% names(output$content))
  
  # Check values
  expect_equal(output$content$mse_mse, c(0.1, 0.2, 0.3), tolerance = 1e-6)
})
