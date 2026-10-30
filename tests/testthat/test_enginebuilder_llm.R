# Tests for the LLM engine builder (build_engine_with_llm_zip)

has_zip <- function() nzchar(Sys.which(Sys.getenv("R_ZIPCMD", "zip")))

test_that("build_engine_with_llm_zip() builds a package for every engine type", {
  skip_if_not(has_zip(), "no zip program available")
  types <- c("split", "execution", "preprocessing", "train", "inprocessing",
             "postprocessing", "eval", "reportelement", "report", "publish")
  for (type in types) {
    zip_file <- tempfile(paste0("llm_", type, "_"), fileext = ".zip")
    out <- suppressMessages(
      build_engine_with_llm_zip(type, "A test description.", zip_path = zip_file)
    )
    expect_true(file.exists(out), info = type)

    exdir <- tempfile("llm_unzip_")
    utils::unzip(out, exdir = exdir)
    expect_length(list.files(exdir), 3)

    prompt_file <- file.path(exdir, paste0("llm_prompt_", type, ".R"))
    expect_true(file.exists(prompt_file), info = type)
    prompt <- readLines(prompt_file, encoding = "UTF-8", warn = FALSE)
    expect_true(any(prompt == paste0("`", type, "`")), info = type)
    expect_true(any(grepl("A test description.", prompt, fixed = TRUE)), info = type)
    expect_false(any(grepl("\\U0001F", prompt, fixed = TRUE)), info = type)

    unlink(c(out, exdir), recursive = TRUE)
  }
})

test_that("build_engine_with_llm_zip() accepts the aliases 'evaluation' and 'publishing'", {
  skip_if_not(has_zip(), "no zip program available")
  aliases <- c(evaluation = "eval", publishing = "publish")
  for (alias in names(aliases)) {
    out <- suppressMessages(
      build_engine_with_llm_zip(alias, "Test.", zip_path = tempfile(fileext = ".zip"))
    )
    files <- utils::unzip(out, list = TRUE)$Name
    expect_true(paste0("llm_prompt_", aliases[[alias]], ".R") %in% files, info = alias)
    unlink(out)
  }
})

test_that("build_engine_with_llm_zip() rejects unknown engine types", {
  expect_error(build_engine_with_llm_zip("unknown", "Test."), "Unsupported engine type")
  expect_error(build_engine_with_llm_zip(c("eval", "split"), "Test."), "single character string")
})
