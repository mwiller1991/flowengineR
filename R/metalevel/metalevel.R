#--------------------------------------------------------------------
### Master-function: Preparation Phase ###
#--------------------------------------------------------------------
#' Execute Initial Fairness Workflow (up to execution)
#'
#' Handles splitting and delegates to execution engine. 
#' If execution is external (e.g. SLURM), the function returns early.
#'
#' @param control A list containing all control parameters and configurations.
#' @return A partial result containing split and execution output.
#' @export
fairness_workflow <- function(control) {
  
  # 1. Call splitter engine
  split_engine <- engines[[control$split_method]]
  split_output <- split_engine(control)
  
  # 2. Choose execution engine
  if (is.null(control$execution)) {
    message("[INFO] No execution engine specified. Using 'execution_sequential' as default.")
    control$execution <- "execution_sequential"
  }
  
  execution_engine <- engines[[control$execution]]
  execution_output <- execution_engine(control, split_output)
  
    # for adaptive procedures, where the split is done in the wrapper
    if (!is.null(execution_output$specific_output$split_output)) {
      split_output <- execution_output$specific_output$split_output
      execution_output$specific_output$split_output <- NULL
    }
  
  # 3. Check for external execution and return early
  if (!isTRUE(execution_output$continue_workflow)) {
    message("[INFO] Execution engine does not continue workflow. Returning after execution.")
    return(list(
      split_output = split_output,
      execution_output = execution_output,
      aggregated_results = NULL,
      reportelements = NULL,
      reports = NULL,
      publishing = NULL
    ))
  }
  
  # 4. Continue workflow
  continue_fairness_workflow(control, split_output, execution_output)
}
#--------------------------------------------------------------------


#--------------------------------------------------------------------
### Continuation Function after Execution ###
#--------------------------------------------------------------------
#' Continue Workflow after Execution
#'
#' Processes the results from the execution engine (aggregation, reporting, publishing).
#'
#' @param control A list containing control parameters and configuration.
#' @param split_output The result of the splitter engine.
#' @param execution_output The result of the execution engine.
#' @return A completed workflow result object.
#' @export
continue_fairness_workflow <- function(control, split_output, execution_output) {
  
  workflow_results <- execution_output$workflow_results
  aggregated_results <- aggregate_results(workflow_results)
  
  # 1. Reportelements (optional)
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
  
  # 2. Reports (optional)
  reports_results <- NULL
  if (!is.null(control$report)) {
    reports_results <- list()
    
    for (alias_report in names(control$report)) {
      engine_name <- control$report[[alias_report]]
      if (!engine_name %in% names(engines)) {
        warning(sprintf("[WARNING] Report engine '%s' not found. Skipping alias '%s'.", engine_name, alias_report))
        next
      }
      
      message(sprintf("[INFO] Running report engine '%s' for alias '%s'...", engine_name, alias_report))
      
      reports_results[[alias_report]] <- engines[[engine_name]](
        control = control,
        reportelements = reportelements_results,
        alias_report = alias_report
      )
    }
  }
  
  # 3. Publishing (optional)
  publishing_results <- list()
  if (!is.null(control$publish)) {
    for (alias_publish in names(control$publish)) {
      
      publish_info <- control$params$publish$params[[alias_publish]]
      obj_type <- publish_info$obj_type
      obj_name <- publish_info$obj_name
      file_path <- file.path(control$params$publish$output_folder, alias_publish)
      
      if (obj_type == "report") {
        object <- reports_results[[obj_name]]
      } else if (obj_type == "reportelement") {
        object <- reportelements_results[[obj_name]]
      } else {
        warning(sprintf("[WARNING] Unknown publish type for '%s': %s", alias_publish, obj_type))
        next
      }
      
      # reportelement to synthetic report
      if (obj_type == "reportelement") {
        compatible_formats <- object$compatible_formats
        object <- initialize_output_report(
          report_title = paste("Export:", alias_publish),
          report_type = "single_element",
          compatible_formats = compatible_formats,
          sections = list(list(
            heading = alias_publish,
            content = list(object)
          ))
        )
      }
      
      engine_name <- control$publish[[alias_publish]]
      if (!engine_name %in% names(engines)) {
        warning(sprintf("[WARNING] Publishing engine '%s' not found. Skipping.", engine_name))
        next
      }
      
      message(sprintf("[INFO] Publishing '%s' with engine '%s'...", alias_publish, engine_name))
      
      publishing_results[[alias_publish]] <- engines[[engine_name]](
        control = control,
        object = object,
        file_path = file_path,
        alias_publish  = alias_publish
      )
    }
  }
  
  # Final result
  return(list(
    split_output = split_output,
    execution_output = execution_output,
    aggregated_results = aggregated_results,
    reportelements = reportelements_results,
    reports = reports_results,
    publishing = publishing_results
  ))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
#' Resume a Fairness Workflow from External Execution Output
#'
#' Resumes the fairness workflow by calling `continue_fairness_workflow()` with a
#' structured resume object that contains the original control, split information,
#' and externally precomputed results (e.g., via SLURM or other deferred execution).
#'
#' @param resume_object A list created by `controller_resume_execution()` containing
#'   - `control`: The original control object.
#'   - `split_output`: The split output from the splitter engine.
#'   - `execution_output`: A valid execution engine output containing `workflow_results`.
#'
#' @return The full result of `continue_fairness_workflow()`, including aggregation,
#' reporting and publishing.
#' @export
resume_fairness_workflow <- function(resume_object) {
  #validation
  validate_resume_object(resume_object)
  
  continue_fairness_workflow(
    control = resume_object$control,
    split_output = resume_object$split_output,
    execution_output = resume_object$execution_output
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