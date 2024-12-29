#--------------------------------------------------------------------
### Workflow Execution with Splitting ###
#--------------------------------------------------------------------
#' Execute workflow with data splitting
#'
#' @param control A control list containing configuration parameters.
#' @return Results of the workflow after splitting the data.
#' @export
run_workflow <- function(control) {
  # Check for user-provided train-test split
  if (!is.null(control$data$train) && !is.null(control$data$test)) {
    message("[INFO] Using user-provided train-test split.")
    return(run_workflow_single(control))
  }
  
  # Default to random split if no split_method is specified
  if (is.null(control$split_method)) {
    message("[INFO] split_method not specified. Defaulting to 'split_random'.")
    control$split_method <- "split_random"
  }
  
  # Perform data splitting using the specified splitter engine
  split_wrapper <- engines[[control$split_method]]
  split_result <- split_wrapper(control)
  
  # The workflow results are generated within the splitter engine itself
  # Return workflow results directly from the splitter
  return(split_result)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### single round master workflow ###
#--------------------------------------------------------------------
#' Run a single iteration of the workflow
#'
#' @param control A list containing all parameters for the workflow.
#' @return A list containing the trained model and predictions.
#' @export
run_workflow_single <- function(control) {
  
  # Check for Train-/Testdata
  if (is.null(control$data$train) || is.null(control$data$test)) {
    stop("[ERROR] Training and test data are missing. Please ensure data is split before execution.")
  }
  
###DEV Memory log after data splitting (remove before productive launch)###
log_memory_usage(env = environment(), label = "at_start")
###DEV-END (remove before productive launch)###
  
  # 1. Assigning data in the meta-level
  # Ensure training data is available for training
  control$params$train$data <- control$data$train
  
  # Ensure test data is available for fairness and evaluation
  control$params$fairness$actuals <- control$data$test[[control$vars$target_var]]
  
  # 2. Fairness Pre-Processing (optional)
  if (!is.null(control$fairness_pre)) {
    pre_fairness_driver <- engines[[control$fairness_pre]]
    control <- pre_fairness_driver(control)
  }
  
###DEV Memory log after pre processing (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_preprocessing")
###DEV-END (remove before productive launch)###
  
  # 3. Training (with optional In-Processing Fairness)
  model_driver <- engines[[control$train_model]]
  if (!is.null(control$fairness_in)) {
    in_fairness_driver <- engines[[control$fairness_in]]
    model_output <- in_fairness_driver(control, model_driver)
  } else {
    model_output <- model_driver(control)
  }
  
    # Generate predictions based on output_type
    if (is.null(control$output_type)) {
      control$output_type <- "prob"
      message("[INFO] output_type not specified. Defaulting to 'prob' for probability outputs.")
    }
    if (control$output_type == "prob") {
      predictions <- as.numeric(predict(model_output$model, newdata = control$data$test, type = "response"))
    } else if (control$output_type == "class") {
      predictions <- predict(model_output$model, newdata = control$data$test, type = "class")
    } else {
      stop("Invalid output_type specified in control.")
    }
  
###DEV Memory log after training (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_training")
###DEV-END (remove before productive launch)###
  
  # 4. Fairness Post-Processing (optional)
  if (!is.null(control$fairness_post)) {
    control$params$fairness$predictions <- predictions
    post_fairness_driver <- engines[[control$fairness_post]]
    predictions <- post_fairness_driver(control)
  }
  
###DEV Memory log after post processing (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_postprocessing")
###DEV-END (remove before productive launch)###
  
  # 5. Evaluation
  control$params$eval$eval_data <- cbind(
    predictions = predictions,
    actuals = control$data$test[[control$vars$target_var]],
    control$data$test[control$vars$protected_vars_eval]
  )
  evaluation_results <- lapply(control$evaluation, function(metric) {
    engines[[metric]](control)
  })
  names(evaluation_results) <- control$evaluation
  
###DEV Memory log after evaluation (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_evaluation")
###DEV-END (remove before productive launch)###
  
  # Return results
  list(
    model = model_output$model,
    predictions = predictions,
    evaluation = evaluation_results
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### full package master workflow ###
#--------------------------------------------------------------------
#' Run multiple workflow variants
#'
#' Executes the workflow in three variants: discrimination-free, best-estimate, and unawareness.
#' @param control The control object containing all parameters.
#' @return A list of results for each variant.
#' @export
run_workflow_variants <- function(control) {
  results <- list()
  
  # 1. discrimination-free workflow
  message("[INFO] Running discrimination-free workflow...")
  results$discriminationfree <- run_workflow(control)
  
  # 2. best-estimate workflow (no fairness adjustments)
  message("[INFO] Running best-estimate workflow (no fairness adjustments)...")
  bestestimate_control <- control
  bestestimate_control$fairness_pre <- NULL
  bestestimate_control$fairness_in <- NULL
  bestestimate_control$fairness_post <- NULL
  results$bestestimate <- run_workflow(bestestimate_control)
  
  # 3. Unawareness workflow (removing protected variables)
  message("[INFO] Running unawareness workflow (removing protected variables)...")
  unawareness_control <- control
  unawareness_control$params$train$formula <- as.formula(paste(
    control$vars$target_var, "~", paste(control$vars$feature_vars, collapse = " + ")
  ))
  results$unawareness <- run_workflow(unawareness_control)
  
  return(results)
}
#--------------------------------------------------------------------