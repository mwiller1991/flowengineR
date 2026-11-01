# All control templates in inst/templates_control must run and use registered engines

test_that("all control templates can be run", {
  dir <- system.file("templates_control", package = "flowengineR")
  files <- list.files(dir, pattern = "\\.R$", full.names = TRUE)
  expect_gt(length(files), 20)
  registered <- names(flowengineR_env$engines)
  for (f in files) {
    env <- new.env()
    env$control <- list()
    expect_error(sys.source(f, envir = env), NA, info = basename(f))
    selected <- unlist(env$control$engine_select, use.names = FALSE)
    expect_true(all(selected %in% registered), info = basename(f))
    for (p in env$control$params$publish$params) {
      expect_false(is.null(p$obj_name), info = basename(f))
    }
  }
})

test_that("the reporting and publishing templates work together", {
  dir <- system.file("templates_control", package = "flowengineR")
  src <- function(name) {
    env <- new.env()
    env$control <- list()
    sys.source(file.path(dir, name), envir = env)
    env$control
  }
  re <- lapply(c("8_a_template_reportelement_text_msesummary.R",
                 "8_b_template_reportelement_table_splitmetrics.R",
                 "8_c_template_reportelement_boxplot_predictions.R"), src)
  rp <- src("9_a_template_report_modelsummary.R")
  pb <- lapply(c("10_a_template_publish_pdf.R", "10_b_template_publish_excel.R"), src)
  control <- list(
    settings = list(log = list(log_show = FALSE)),
    engine_select = list(
      evaluation = c("eval_mse", "eval_summarystats"),
      reportelement = do.call(c, lapply(re, function(x) x$engine_select$reportelement)),
      report = rp$engine_select$report,
      publish = do.call(c, lapply(pb, function(x) x$engine_select$publish))
    ),
    params = list(
      reportelement = controller_reportelement(
        params = do.call(c, lapply(re, function(x) x$params$reportelement$params))
      ),
      report = rp$params$report,
      publish = controller_publish(
        output_folder = tempdir(),
        params = do.call(c, lapply(pb, function(x) x$params$publish$params))
      )
    )
  )
  res <- run_workflow(control)
  expect_s3_class(res$reportelements$pred_plot_gender$content, "ggplot")
  expect_true(res$publishing$export_excel$success)
  expect_true(file.exists(res$publishing$export_excel$path))
  if (can_render_pdf()) {
    expect_true(res$publishing$main_pdf$success)
    expect_true(file.exists(res$publishing$main_pdf$path))
  }
  unlink(c(res$publishing$export_excel$path, res$publishing$main_pdf$path))
})
