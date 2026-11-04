# flowengineR_start(): engine overview of menu item 4

test_that("the engine overview lists the engines of each type", {
  lines <- format_engine_overview(list_registered_engines())
  expect_true(any(grepl("^train: +train_lm, train_glm, train_gbm$", lines)))
  expect_true(any(grepl("execution_basic_sequential", lines)))
  expect_true(any(grepl("^publish: +publish_pdf_basis, publish_excel_basis$", lines)))
  expect_true(all(nchar(lines) <= 80))
})
