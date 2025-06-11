test_that("wrapper_execution_basic_sequential executes all splits and returns standardized output", {
  # Dummy dataset
  set.seed(123)
  full_data <- data.frame(
    y = rnorm(100),
    x1 = rnorm(100),
    x2 = rnorm(100)
  )
  
  # Create two splits manually
  splits <- list(
    split1 = list(train = full_data[1:50, ], test = full_data[51:100, ]),
    split2 = list(train = full_data[51:100, ], test = full_data[1:50, ])
  )
  
  split_output <- list(splits = splits)
  
  # Minimal control with dummy engine selection
  control <- list(
    data = list(vars = list(target_var = "y")),
    settings = list(
      log = list(log_show = FALSE),
      output_type = "response"
    ),
    params = list(
      train = controller_training(formula = y ~ x1 + x2, norm_data = FALSE),
      evaluation = controller_evaluation(),
      execution = controller_execution(params = list())
    ),
    engine_select = list(
      train = "train_glm",
      evaluation = "eval_mse"
    )
  )
  
  # Register required wrappers
  flowengineR_env$engines[["train_glm"]] <- wrapper_train_glm
  flowengineR_env$engines[["eval_mse"]] <- wrapper_eval_mse
  
  # Local override of run_workflow_singlesplitloop
  run_workflow_singlesplitloop <- function(ctrl) {
    model <- flowengineR_env$engines[[ctrl$engine_select$train]](ctrl)
    eval <- flowengineR_env$engines[[ctrl$engine_select$evaluation]](list(
      params = list(eval = controller_evaluation(
        eval_data = list(
          predictions = model$predictions,
          actuals = ctrl$data$test$y
        )
      )),
      settings = list(log = list(log_show = FALSE))
    ))
    list(output_eval = list(eval_mse = eval))
  }
  
  # Run wrapper
  output <- wrapper_execution_basic_sequential(control, split_output)
  
  # Basic structure check
  expect_type(output, "list")
  expect_named(output, c("execution_type", "workflow_results", "continue_workflow",  "params", "specific_output"))
  expect_equal(output$execution_type, "basic_sequential")
  expect_true(output$continue_workflow)
  
  # Check number of results
  expect_type(output$workflow_results, "list")
  expect_length(output$workflow_results, 2)
  expect_true(all(c("split1", "split2") %in% names(output$workflow_results)))
})
