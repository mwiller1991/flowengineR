test_that("wrapper_report_modelsummary assembles a structured multi-section report with real plots", {
  skip_if_not_installed("ggplot2")
  
  library(ggplot2)
  
  # Dummy plot data
  data <- data.frame(
    prediction = rnorm(100),
    gender = sample(c("male", "female"), 100, replace = TRUE),
    age_group = sample(c("young", "middle", "old"), 100, replace = TRUE)
  )
  
  # Create real ggplot objects
  gender_plot <- ggplot(data, aes(x = gender, y = prediction)) +
    geom_boxplot() +
    ggtitle("Prediction by Gender")
  
  age_plot <- ggplot(data, aes(x = age_group, y = prediction)) +
    geom_boxplot() +
    ggtitle("Prediction by Age")
  
  # Simulated reportelements with real plots
  reportelements <- list(
    mse_text = list(type = "text", content = "MSE is 0.123", compatible_formats = c("pdf", "html")),
    pred_plot_gender = list(type = "plot", content = gender_plot, compatible_formats = c("pdf", "html")),
    pred_plot_age = list(type = "plot", content = age_plot, compatible_formats = c("pdf", "html")),
    split_table = list(type = "table", content = data.frame(mse = c(0.1, 0.2)), compatible_formats = c("pdf", "html"))
  )
  
  # Control object with aliases
  control <- list(
    settings = list(log = list(log_show = FALSE)),
    params = list(
      report = controller_report(params = list(
        main_report = list(
          mse_text = "mse_text",
          gender_box = "pred_plot_gender",
          age_box = "pred_plot_age",
          metrics_table = "split_table"
        )
      ))
    )
  )
  
  # Run wrapper
  output <- wrapper_report_modelsummary(control, reportelements, alias_report = "main_report")
  
  # Structure checks
  expect_type(output, "list")
  expect_named(output, c("report_title", "report_type", "compatible_formats", "sections", "params"))
  expect_equal(output$report_title, "Modellzusammenfassung")
  expect_equal(output$report_type, "modelsummary")
  expect_type(output$sections, "list")
  expect_length(output$sections, 3)
  
  # Section headings
  expect_equal(output$sections[[1]]$heading, "MSE")
  expect_equal(output$sections[[2]]$heading, "Visualisierung")
  expect_equal(output$sections[[3]]$heading, "Metriken")
  
  # Check plot types
  expect_s3_class(output$sections[[2]]$content[[1]]$content, "gg")
  expect_s3_class(output$sections[[2]]$content[[2]]$content, "gg")
})
