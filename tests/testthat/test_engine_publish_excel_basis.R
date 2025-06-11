test_that("wrapper_publish_excel_basis creates Excel file from report object", {
  skip_if_not_installed("openxlsx")  # skip on systems without openxlsx
  
  # Minimal valid report object
  report <- list(
    report_title = "Test Report",
    report_type = "modelsummary",
    compatible_formats = c("pdf", "xlsx"),
    sections = list(
      list(
        heading = "Test Section",
        content = list(
          list(type = "text", content = "Example text", compatible_formats = "pdf"),
          list(type = "table", content = data.frame(a = 1:3, b = letters[1:3]), compatible_formats = "pdf")
        )
      )
    )
  )
  
  # Control object
  control <- list(
    settings = list(log = list(log_show = FALSE)),
    params = list(
      publish = controller_publish(params = list(
        export_excel = list(obj_type = "report")
      ))
    )
  )
  
  # Temporary file path
  path_base <- tempfile("test_report")
  
  # Run wrapper
  output <- wrapper_publish_excel_basis(
    control = control,
    object = report,
    file_path = path_base,
    alias_publish = "export_excel"
  )
  
  # Validate output structure
  expect_type(output, "list")
  expect_true(output$success)
  expect_equal(output$type, "report")
  expect_equal(output$engine, "publish_excel_basis")
  expect_true(file.exists(output$path))
  
  # Cleanup
  unlink(output$path)
})
