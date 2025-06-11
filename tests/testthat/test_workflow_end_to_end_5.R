test_that("run_workflow executes a full end-to-end workflow without error", {

  # Dummy dataset
  set.seed(42)
  dummy_data <- data.frame(
    default = rnorm(100),
    x1 = rnorm(100),
    x2 = rnorm(100),
    protected = sample(c(0, 1), 100, replace = TRUE),
    protected2 = sample(c(0, 1), 100, replace = TRUE)
  )
  
  dummy_vars <- controller_vars(
    target_var = "default",
    protected_vars = c("protected", "protected2"),
    protected_vars_binary = c("protected", "protected2"),
    feature_vars = c("x1", "x2")
  )
  
  # Construct control object
  control <- list(
    settings = list(
      log = list(
        log_show = FALSE
      ),
      output_type = "response"
    ),
    data = list(
      full = dummy_data,
      vars = dummy_vars
    ),
    engine_select = list(
      split = "split_random_stratified",
      execution = "execution_adaptive_output_batchtools_multicore",
      preprocessing = "preprocessing_fairness_resampling",
      train = "train_lm",
      postprocessing = "postprocessing_fairness_genresidual",
      evaluation = list(
        "eval_mse", 
        "eval_summarystats", 
        "eval_statisticalparity"
      ),
      reportelement = list(
        box_adjusted = "reportelement_boxplot_predictions",
        box2 = "reportelement_boxplot_predictions",
        metrics_table = "reportelement_table_splitmetrics",
        text_mse_summary = "reportelement_text_msesummary"
      ),
      report = list(
        modelsummary = "report_modelsummary"
      ),
      publish = list(
        pdf_basis_test_report = "publish_pdf_basis",
        pdf_basis_test_singleelement = "publish_pdf_basis",
        excel_basis_test_singleelement = "publish_excel_basis"
      )
    ),
    params = list(
      split = controller_split(
        seed = 123
      ),
      execution = controller_execution(
        params = list(
          registry_folder = tempdir()
        )
      ),
      preprocessing = controller_preprocessing(
        params = list(
          method = "oversampling"
        )
      ),
      train = controller_training(
        formula = as.formula(paste(dummy_vars$target_var, "~", paste(dummy_vars$feature_vars, collapse = "+"), "+", paste(dummy_vars$protected_vars, collapse = "+"))),
        norm_data = TRUE
      ),
      postprocessing = controller_postprocessing(),
      evaluation = controller_evaluation(),
      reportelement = controller_reportelement(
        params = list(
          box_adjusted = list(group_var = "protected", source = "train"),
          box2 = list(group_var = "protected"),
          metrics_table = list(metrics = c("mse", "statisticalparity", "summarystats")),
          text_mse_summary = list()
        )
      ),
      report = controller_report(
        params = list(
          modelsummary = list(
            mse_text = "text_mse_summary",
            gender_box = "box_adjusted",
            age_box = "box2",
            metrics_table = "metrics_table")
        )
      ),
      publish = controller_publish(
        output_folder = tempdir(),
        params = list(
          pdf_basis_test_singleelement = list(obj_name = "text_mse_summary", obj_type = "reportelement"),
          pdf_basis_test_report = list(obj_name = "modelsummary", obj_type = "report"),
          excel_basis_test_singleelement = list(obj_name = "metrics_table", obj_type = "reportelement")
        )
      )
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
  
  # Reportelements
  expect_type(result$reportelements, "list")
  expect_true("box_adjusted" %in% names(result$reportelements))
  expect_true("box2" %in% names(result$reportelements))
  expect_true("metrics_table" %in% names(result$reportelements))
  expect_true("text_mse_summary" %in% names(result$reportelements))
  expect_s3_class(result$reportelements$box_adjusted$content, "ggplot")
  expect_s3_class(result$reportelements$box2$content, "ggplot")
  expect_s3_class(result$reportelements$metrics_table$content, "data.frame")
  expect_type(result$reportelements$text_mse_summary$content, "character")
  
  # Reports
  expect_type(result$reports, "list")
  expect_true("modelsummary" %in% names(result$reports))
  expect_equal(result$reports$modelsummary$report_type, "modelsummary")
  
  # Publishing
  expect_type(result$publishing, "list")
  expect_true("pdf_basis_test_singleelement" %in% names(result$publishing))
  expect_true("pdf_basis_test_report" %in% names(result$publishing))
  expect_true("excel_basis_test_singleelement" %in% names(result$publishing))
  expect_true(result$publishing$pdf_basis_test_singleelement$success)
  expect_true(result$publishing$pdf_basis_test_report$success)
  expect_true(result$publishing$excel_basis_test_singleelement$success)
  expect_true(file.exists(result$publishing$pdf_basis_test_singleelement$path))
  expect_true(file.exists(result$publishing$pdf_basis_test_report$path))
  expect_true(file.exists(result$publishing$excel_basis_test_singleelement$path))
  
  # Cleanup exported file
  unlink(result$publishing$pdf_basis_test_singleelement$path)
  unlink(result$publishing$pdf_basis_test_report$path)
  unlink(result$publishing$excel_basis_test_singleelement$path)
})
