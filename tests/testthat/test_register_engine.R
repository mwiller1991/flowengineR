# register_engine(): the validation must not change the random number state

test_that("register_engine() leaves the random number state of the session unchanged", {
  quietly <- function(expr) suppressMessages(invisible(utils::capture.output(expr)))

  # evaluation engine: the validation uses random dummy data
  eval_file <- system.file("llm_demonstrations", "2025-08-29_eval_median", "outputs",
                           "engine_eval_median.R", package = "flowengineR")
  set.seed(1)
  before <- .Random.seed
  quietly(register_engine("eval_median", eval_file))
  expect_identical(.Random.seed, before)

  # splitter engine: the validation runs the splitter, which sets a seed
  split_file <- tempfile(fileext = ".R")
  code <- readLines(system.file("example_enginebuild_LLM", "engine_split_random.R",
                                package = "flowengineR"), warn = FALSE)
  writeLines(gsub("split_random", "split_randomcopy", code), split_file)
  set.seed(2)
  before <- .Random.seed
  quietly(register_engine("split_randomcopy", split_file))
  expect_identical(.Random.seed, before)
  expect_true("split_randomcopy" %in% names(list_registered_engines("split")))

  # remove the test engines from the registry again
  flowengineR_env$engines[["split_randomcopy"]] <- NULL
  flowengineR_env$engines[["eval_median"]] <- NULL
  unlink(split_file)
})
