#--------------------------------------------------------------------
### Master-function ###
#--------------------------------------------------------------------
#' Execute Full Fairness Workflow across Data Splits
#'
#' Orchestrates the complete fairness-aware modeling pipeline, including:
#' - Splitting via splitter engine
#' - Iterative execution of run_workflow_single() per split
#' - Aggregation of evaluation results
#' - Reporting und Publishing
#'
#' @param control A list containing all control parameters and configurations.
#' @return A standardized workflow result with all sub-results embedded.
#' @export
fairness_workflow <- function(control) {
  
  # 1. Call splitter engine
  split_engine <- engines[[control$split_method]]
  split_output <- split_engine(control)
  
  # 2. Iterate over all splits
  workflow_results <- lapply(split_output$splits, function(split) {
    control$data$train <- split$train
    control$data$test <- split$test
    run_workflow_single(control)
  })
  
  # 3. Aggregate results (e.g. metrics)
  aggregated_results <- aggregate_results(workflow_results)
  
  # 4. Reportelements (optional)
  reportelements_results <- NULL
  if (!is.null(control$reportelement)) {
    reportelements_results <- list()
    
    for (alias in names(control$reportelement)) {
      engine_name <- control$reportelement[[alias]]
      if (!engine_name %in% names(engines)) {
        warning(sprintf("[WARNING] Reportelement engine '%s' not found. Skipping alias '%s'.", engine_name, alias))
        next
      }
      
      message(sprintf("[INFO] Running reportelement engine '%s' for alias '%s'...", engine_name, alias))
      
      reportelements_results[[alias]] <- engines[[engine_name]](
        control = control,
        workflow_results = workflow_results,
        split_output = split_output,
        alias = alias
      )
    }
  }
  
  # 4. Return full structured result
  list(
    split_output = split_output,
    workflow_results = workflow_results,
    aggregated_results = aggregated_results,
    reportelements = reportelements_results
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
fairness_workflow_variants <- function(control) {
  results <- list()
  
  # 1. discrimination-free workflow
  message("[INFO] Running discrimination-free workflow...")
  results$discriminationfree <- fairness_workflow(control)
  
  # 2. best-estimate workflow (no fairness adjustments)
  message("[INFO] Running best-estimate workflow (no fairness adjustments)...")
  bestestimate_control <- control
  bestestimate_control$fairness_pre <- NULL
  bestestimate_control$fairness_in <- NULL
  bestestimate_control$fairness_post <- NULL
  results$bestestimate <- fairness_workflow(bestestimate_control)
  
  # 3. Unawareness workflow (removing protected variables)
  message("[INFO] Running unawareness workflow (removing protected variables)...")
  unawareness_control <- control
  unawareness_control$params$train$formula <- as.formula(paste(
    control$vars$target_var, "~", paste(control$vars$feature_vars, collapse = " + ")
  ))
  unawareness_control$fairness_pre <- NULL
  unawareness_control$fairness_in <- NULL
  unawareness_control$fairness_post <- NULL
  results$unawareness <- fairness_workflow(unawareness_control)
  
  return(results)
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
  
  # Initialize results list
  results <- list()
  
###DEV Memory log after data splitting (remove before productive launch)###
log_memory_usage(env = environment(), label = "at_start")
###DEV-END (remove before productive launch)###
  
  # 1. Assigning data in the meta-level (for the case no Pre-Processing is operated)
  # Ensure training data is available for training
  control$params$train$data <- control$data$train
  
  # 2. Fairness Pre-Processing (optional)
  if (!is.null(control$fairness_pre)) {
    control$params$fairness_pre$data <- control$data$train
    driver_fairness_pre <- engines[[control$fairness_pre]]
    output_fairness_pre <- driver_fairness_pre(control) #-> Change later on just for the changed predictions after remodelling the pre-methods
    
    # Overwrite data by preprocessed data
    control$params$train$data <- output_fairness_pre$preprocessed_data
    
    results$output_fairness_pre <- output_fairness_pre
  }
  
  # 3. Normalization based on training data parameters
  # Compute min-max parameters only from the (possibly preprocessed) training data
  norm_params <- compute_minmax_params(
    data = control$params$train$data,
    feature_names = c(control$vars$feature_vars, control$vars$protected_vars, control$vars$target_var)
  )
  
  # Apply the same normalization to train, test, and control$params$train$data
  control$data$train <- list(
    original = control$data$train,
    normalized = apply_minmax_params(control$data$train, norm_params)
  )
  
  control$data$test <- list(
    original = control$data$test,
    normalized = apply_minmax_params(control$data$test, norm_params)
  )
  
  control$params$train$data <- list(
    original = control$params$train$data,
    normalized = apply_minmax_params(control$params$train$data, norm_params)
  )
  
  
###DEV Memory log after pre processing (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_preprocessing")
###DEV-END (remove before productive launch)###
  
  # 4.1 Training (Base)
  driver_train <- engines[[control$train_model]]
  
    # Always do the base training
    output_train <- driver_train(control)
    
    # Choosing testdata for 4.1, 4.2 and 5 for prediction (normalized/original)
    if (control$params$train$norm_data == TRUE) {
      testdata <- control$data$test$normalized
    } else if (control$params$train$norm_data == FALSE) {
      testdata <- control$data$test$original
    } else {
      stop("Normalization is not properly choosen.")
    }
    
    # Generate predictions based on output_type
    if (is.null(control$output_type)) {
      control$output_type <- "response"
      message("[INFO] output_type not specified. Defaulting to 'response' for outputs.")
    }
    if (control$output_type == "prob") {
      predictions <- as.numeric(predict(output_train$model, newdata = testdata, type = "prob"))
    } else if (control$output_type == "response") {
      predictions <- as.numeric(predict(output_train$model, newdata = testdata, type = "response"))
        if (control$params$train$norm_data == TRUE) {
          predictions <- denormalize_predictions(predictions, control$vars$target_var, norm_params)
        }
    } else {
      stop("Invalid output_type specified in control.")
    }
    
    # Add predictions to the training-output
    output_train$predictions <- predictions
    
    # Add train to the output
    results$output_train <- output_train
  
  # 4.2 Training (with In-Processing Fairness)
  if (!is.null(control$fairness_in)) {
    driver_fairness_in <- engines[[control$fairness_in]]
    output_fairness_in <- driver_fairness_in(control, driver_train)
    
      # Generate predictions for In-Processing based on output_type
      if (control$output_type == "prob") {
        predictions <- as.numeric(predict(output_fairness_in$adjusted_model, newdata = testdata, type = "prob"))
      } else if (control$output_type == "response") {
        predictions <- as.numeric(predict(output_fairness_in$adjusted_model, newdata = testdata, type = "response"))
          if (control$params$train$norm_data == TRUE) {
            predictions <- denormalize_predictions(predictions, control$vars$target_var, norm_params)
          }
      } else {
        stop("Invalid output_type specified in control.")
      }
      
      # Add predictions to the training-output
      output_fairness_in$predictions <- predictions
      
      # Add train to the output
      results$output_fairness_in <- output_fairness_in
  }
  
###DEV Memory log after training (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_training")
###DEV-END (remove before productive launch)###
  
  # 5. Fairness Post-Processing (optional)
  if (!is.null(control$fairness_post)) {
    
    control$params$fairness_post$fairness_post_data <- cbind(
      predictions = as.numeric(predictions),
      actuals = testdata[[control$vars$target_var]],
      testdata[control$vars$protected_vars_binary]
    )
    
    driver_fairness_post <- engines[[control$fairness_post]]
    output_fairness_post <- driver_fairness_post(control)
    predictions <- as.numeric(output_fairness_post$adjusted_predictions)
    
    results$output_fairness_post <- output_fairness_post
  }
  
###DEV Memory log after post processing (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_postprocessing")
###DEV-END (remove before productive launch)###
  
  # 6. Evaluation
  if (!is.null(control$evaluation)) {
    control$params$eval$eval_data <- cbind(
      predictions = predictions,
      actuals = control$data$test$original[[control$vars$target_var]],
      control$data$test$original[control$vars$protected_vars_binary]
    )
    
    output_eval <- lapply(control$evaluation, function(metric) {
      engines[[metric]](control)
    })
    names(output_eval) <- control$evaluation
    results$output_eval <- output_eval
  }
  
###DEV Memory log after evaluation (remove before productive launch)###
log_memory_usage(env = environment(), label = "after_evaluation")
###DEV-END (remove before productive launch)###


  # Save normalization parameters only if normalization was applied
  if (isTRUE(control$params$train$norm_data)) {
    results$normalization <- list(
      params = norm_params,
      method = "minmax",
      based_on = "train_data",
      feature_names = c(control$vars$feature_vars, control$vars$protected_vars, control$vars$target_var)
    )
  }
  
  # Return results
  return(results)
}
#--------------------------------------------------------------------