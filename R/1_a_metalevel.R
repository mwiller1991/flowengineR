#--------------------------------------------------------------------
### Master-function: Preparation Phase ###
#--------------------------------------------------------------------
#' Run a Modular Workflow (Preparation and Execution Phase)
#'
#' This function initiates a full modular algorithmic workflow by handling the preparation phase. 
#' It calls the specified splitter engine to create data partitions and passes the result to the chosen execution engine. 
#' Depending on the execution setup, the function may return early (e.g. if a batchtools-based external execution such as SLURM is used), 
#' or directly continue with downstream processing via `continue_workflow()`.
#'
#' **Inputs:**
#' - `control`: A standardized control object. This must contain all relevant components for the workflow:
#'   - `flowengineR_env$engines`: A list with the used engines.
#'      - `split`: Name of a registered splitter engine (e.g. "split_random_stratified")
#'      - `execution`: Name of a registered execution engine (optional; defaults to "execution_sequential")
#'   - `params`: Parameter structure used by downstream engines (e.g., split ratio, seeds, evaluation metrics)
#'
#' **Output:**
#' - If the execution engine returns early (e.g. external execution), the function returns a partial result with:
#'   - `split_output`: Result of the splitting process
#'   - `execution_output`: Result of the execution engine
#'   - `aggregated_results`, `reportelements`, `reports`, `publishing`: All `NULL`
#'
#' - If the execution continues within the R session, the function delegates to `continue_workflow()` and returns:
#'   - Full structured workflow result, including post-execution outputs
#'
#' **Usage Context:**
#' - This is the main entry point into the framework.
#' - It is intended to be called by users who wish to run training, (optional) pre-/in-/post-processing, evaluation, reporting, and publishing in a single pipeline.
#'
#' @param control A standardized list structure containing all workflow instructions and parameters. Created manually or via controller functions.
#'
#' @return A structured list containing at least `split_output` and `execution_output`. Additional elements may be included depending on the workflow stage.
#' @export
run_workflow <- function(control = list()) {
  log_msg("[MASTER] Initializing control object with defaults...", level = "info", control = control)
  control <- complete_control_with_defaults(control)
  
  # 1. Call splitter engine
  log_msg(paste0("[MASTER] Using split engine: ", control$engine_select$split), level = "info", control = control)
  control$params$split$target_var <- control$data$vars$target_var
  split_engine <- flowengineR_env$engines[[control$engine_select$split]]
  split_output <- split_engine(control)
  
  # 2. Choose execution engine
  log_msg(paste0("[MASTER] Using execution engine: ", control$engine_select$execution), level = "info", control = control)
  execution_engine <- flowengineR_env$engines[[control$engine_select$execution]]
  execution_output <- execution_engine(control, split_output)
  
  # for adaptive procedures, where the split is done in the wrapper
  if (!is.null(execution_output$specific_output$split_output)) {
    split_output <- execution_output$specific_output$split_output
    execution_output$specific_output$split_output <- NULL
  }
  
  # 3. Early return (external execution)
  if (!isTRUE(execution_output$continue_workflow)) {
    log_msg("[MASTER] Execution completed externally. Returning early.", level = "info", control = control)
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
  log_msg("[MASTER] Proceeding to reporting and publishing...", level = "info", control = control)
  continue_workflow(control, split_output, execution_output)
}
#--------------------------------------------------------------------


#--------------------------------------------------------------------
### Continuation Function after Execution ###
#--------------------------------------------------------------------
#' Continue the Workflow after Execution Phase
#'
#' This function completes a modular workflow by performing post-execution steps:
#' - Aggregates the raw results from multiple workflow runs,
#' - Optionally generates reporting elements and full reports using registered reporting engines,
#' - Optionally calls publishing engines to export final results to external formats.
#'
#' **Inputs:**
#' - `control`: A standardized control object. Must contain instructions for reporting and publishing if applicable.
#' - `split_output`: The output from the splitting engine, used for report contextualization.
#' - `execution_output`: Output returned from the execution engine, including raw workflow results.
#'
#' **Output:**
#' - A named list with all downstream results:
#'   - `split_output`: Returned as passed.
#'   - `execution_output`: Returned as passed.
#'   - `aggregated_results`: Aggregated evaluation metrics across splits.
#'   - `reportelements`: Optional list of individual reporting element outputs (if specified).
#'   - `reports`: Optional list of final reports (if specified).
#'   - `publishing`: Optional list of results from publishing engines (if specified).
#'
#' **Usage Context:**
#' - Automatically called within `run_workflow()` unless the execution engine is configured to terminate early.
#' - May also be called manually (e.g., from `resume_workflow()`) to finalize an externally executed pipeline.
#'
#' @param control A standardized list that controls the reporting and publishing steps.
#' @param split_output The result of the splitting engine, required for contextual reports.
#' @param execution_output A valid result from an execution engine, including `workflow_results`.
#'
#' @return A named list containing the full workflow results, including aggregation, reports and published outputs.
#' @export
continue_workflow <- function(control, split_output, execution_output) {
  log_msg("[CONTINUE] Aggregating workflow results...", level = "info", control = control)
  workflow_results <- execution_output$workflow_results
  aggregated_results <- aggregate_results(workflow_results)
  
  # 1. Reportelements (optional)
  reportelements_results <- NULL
  if (!is.null(control$engine_select$reportelement)) {
    log_msg("[CONTINUE] Generating reportelements...", level = "info", control = control)
    reportelements_results <- list()
    for (alias in names(control$engine_select$reportelement)) {
      engine_name <- control$engine_select$reportelement[[alias]]
      if (!engine_name %in% names(flowengineR_env$engines)) {
        log_msg(sprintf("[WARNING] Reportelement engine '%s' not found. Skipping alias '%s'.", engine_name, alias), level = "warn", control = control)
        next
      }
      log_msg(sprintf("[CONTINUE] Running reportelement engine '%s' for alias '%s'...", engine_name, alias), level = "debug", control = control)
      reportelements_results[[alias]] <- flowengineR_env$engines[[engine_name]](
        control = control,
        workflow_results = workflow_results,
        split_output = split_output,
        alias = alias
      )
    }
  }
  
  # 2. Reports (optional)
  reports_results <- NULL
  if (!is.null(control$engine_select$report)) {
    log_msg("[CONTINUE] Generating full reports...", level = "info", control = control)
    reports_results <- list()
    for (alias_report in names(control$engine_select$report)) {
      engine_name <- control$engine_select$report[[alias_report]]
      if (!engine_name %in% names(flowengineR_env$engines)) {
        log_msg(sprintf("[WARNING] Report engine '%s' not found. Skipping alias '%s'.", engine_name, alias_report), level = "warn", control = control)
        next
      }
      log_msg(sprintf("[CONTINUE] Running report engine '%s' for alias '%s'...", engine_name, alias_report), level = "debug", control = control)
      reports_results[[alias_report]] <- flowengineR_env$engines[[engine_name]](
        control = control,
        reportelements = reportelements_results,
        alias_report = alias_report
      )
    }
  }
  
  # 3. Publishing (optional)
  publishing_results <- list()
  if (!is.null(control$engine_select$publish)) {
    log_msg("[CONTINUE] Running publishing engines...", level = "info", control = control)
    for (alias_publish in names(control$engine_select$publish)) {
      publish_info <- control$params$publish$params[[alias_publish]]
      obj_type <- publish_info$obj_type
      obj_name <- publish_info$obj_name
      file_path <- file.path(control$params$publish$output_folder, alias_publish)
      
      if (obj_type == "report") {
        object <- reports_results[[obj_name]]
      } else if (obj_type == "reportelement") {
        object <- reportelements_results[[obj_name]]
      } else {
        log_msg(sprintf("[WARNING] Unknown publish type for '%s': %s", alias_publish, obj_type), level = "warn", control = control)
        next
      }
      
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
      
      engine_name <- control$engine_select$publish[[alias_publish]]
      if (!engine_name %in% names(flowengineR_env$engines)) {
        log_msg(sprintf("[WARNING] Publishing engine '%s' not found. Skipping.", engine_name), level = "warn", control = control)
        next
      }
      
      log_msg(sprintf("[CONTINUE] Publishing '%s' with engine '%s'...", alias_publish, engine_name), level = "debug", control = control)
      publishing_results[[alias_publish]] <- flowengineR_env$engines[[engine_name]](
        control = control,
        object = object,
        file_path = file_path,
        alias_publish  = alias_publish
      )
    }
  }
  
  log_msg("[CONTINUE] Workflow fully completed.", level = "info", control = control)
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
### Resuming workflow ###
#--------------------------------------------------------------------
#' Resume a Workflow After External Execution
#'
#' This function allows a previously initiated modular workflow to be resumed after execution 
#' was completed outside of R (e.g., via SLURM, batchtools, or other deferred backends).  
#' It expects a structured resume object and internally calls `continue_workflow()` 
#' to complete all post-execution steps such as aggregation, reporting, and publishing.
#'
#' **Inputs:**
#' - `resume_object`: A list created by `controller_resume_execution()`, containing:
#'   - `control`: The original control object passed to the initial workflow.
#'   - `split_output`: Output of the splitter engine used before execution.
#'   - `execution_output`: A valid execution engine output, including `workflow_results`.
#'
#' **Output:**
#' - A full workflow result object as returned by `continue_workflow()`:
#'   - `split_output`, `execution_output`
#'   - `aggregated_results`: Summary across workflow runs
#'   - `reportelements`, `reports`, `publishing`: If configured in the control
#'
#' **Usage Context:**
#' - Intended for use after asynchronous or parallel execution completed externally
#' - Enables full integration of batchtools or SLURM workflows into the modular pipeline
#'
#' @param resume_object A structured list returned by `controller_resume_execution()`, containing all necessary components to resume the workflow.
#'
#' @return A named list as returned by `continue_workflow()`, including all optional post-processing results.
#' @export
resume_workflow <- function(resume_object) {
  validate_resume_object(resume_object)
  log_msg("[RESUME] Resuming workflow after external execution...", level = "info", control = resume_object$control)
  continue_workflow(
    control = resume_object$control,
    split_output = resume_object$split_output,
    execution_output = resume_object$execution_output
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### single round master workflow ###
#--------------------------------------------------------------------
#' Run a Single Workflow Iteration (One Train/Test Split)
#'
#' Executes a complete algorithmic workflow for a single split of training and test data. 
#' Supports optional preprocessing, in-processing, post-processing, evaluation, and normalization steps, 
#' all controlled by user-defined engine specifications. 
#'
#' This function is publicly accessible and is designed to be used within execution engines, 
#' including sequential and parallel workflows (e.g., via batchtools or SLURM). 
#'
#' **Inputs (from control object):**
#' - `control$data$train`: Training data (data.frame).
#' - `control$data$test`: Test data (data.frame).
#' - `control$data$vars`: A list including:
#'   - `feature_vars`: Input variables used for training
#'   - `target_var`: Target variable
#'   - `protected_vars`: (Optional) Variables used for protected group analyses
#'   - `protected_vars_binary`: (Optional) Binary indicators for group-specific evaluation
#' - `control$params$train`: Model training configuration.
#' - `control$settings$output_type`: Either `"response"` or `"prob"` (default: `"response"`).
#' - Optional modules (if configured):
#'   - `control$engine_select$preprocessing`: Name of preprocessing engine
#'   - `control$engine_select$inprocessing`: Name of in-processing engine
#'   - `control$engine_select$postprocessing`: Name of post-processing engine
#'   - `control$engine_select$evaluation`: Vector of evaluation engine names
#'
#' **Output:**
#' A named list with standardized results:
#' - `output_train`: Base model and predictions
#' - `output_preprocessing`: (if used) Preprocessed training data
#' - `output_inprocessing`: (if used) Adjusted model and predictions
#' - `output_postprocessing`: (if used) Adjusted predictions
#' - `output_eval`: (if used) Evaluation results
#' - `normalization`: Parameters and method used for normalization (if applied)
#'
#' **Usage Notes:**
#' - Input data must already be split before calling this function.
#' - Normalization is based on training data and applied consistently to test data.
#' - Engines must follow the standardized input/output format to be compatible.
#' - This function is typically called internally by execution engines.
#'
#' @param control A fully specified control object for a single train/test split.
#'
#' @return A list with all outputs generated by the configured engines during this workflow iteration.
#' @export
run_workflow_singlesplitloop <- function(control) {

  log_msg("[SINGLE] Starting single workflow iteration...", level = "info", control = control)

  if (is.null(control$data$train) || is.null(control$data$test)) {
    stop("[ERROR] Training and test data are missing. Please ensure data is split before execution.")
  } else {
    log_msg("[SINGLE] Train/test data successfully detected.", level = "info", control = control)
  }

  results <- list()

  # Step 1: Assign raw training data
  control$params$train$data <- control$data$train

  # Step 2: Preprocessing (if defined)
  if (!is.null(control$engine_select$preprocessing)) {
    log_msg(paste0("[SINGLE] Running preprocessing engine: ", control$engine_select$preprocessing), level = "info", control = control)
    control$params$preprocessing$data <- control$data$train
    control$params$preprocessing$protected_attributes <- control$data$vars$protected_vars
    control$params$preprocessing$target_var <- control$data$vars$target_var
    driver_pre <- flowengineR_env$engines[[control$engine_select$preprocessing]]
    output_pre <- driver_pre(control)
    control$params$train$data <- output_pre$preprocessed_data
    results$output_preprocessing <- output_pre
    log_msg("[SINGLE] Preprocessing completed.", level = "debug", control = control)
  }

  # Step 3: Normalization
  log_msg("[SINGLE] Normalizing datasets (based on training)...", level = "info", control = control)
  norm_params <- compute_minmax_params(
    data = control$params$train$data,
    feature_names = c(control$data$vars$feature_vars, control$data$vars$protected_vars, control$data$vars$target_var)
  )
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
  log_msg("[SINGLE] Normalization complete.", level = "debug", control = control)
  
  # Step 4: Model training
  log_msg(paste0("[SINGLE] Training base model: ", control$engine_select$train), level = "info", control = control)
  driver_train <- flowengineR_env$engines[[control$engine_select$train]]
  output_train <- driver_train(control)

  # Step 4.2: Select prediction data
  if (control$params$train$norm_data == TRUE) {
    testdata <- control$data$test$normalized
  } else if (control$params$train$norm_data == FALSE) {
    testdata <- control$data$test$original
  } else {
    stop("Normalization is not properly choosen.")
  }
  
  # Step 4.3: Prediction
  log_msg("[SINGLE] Generating predictions from base model...", level = "debug", control = control)
  if (control$settings$output_type == "prob") {
    predictions <- as.numeric(predict(output_train$model, newdata = testdata, type = "prob"))
  } else if (control$settings$output_type == "response") {
    predictions <- as.numeric(predict(output_train$model, newdata = testdata, type = "response"))
    if (control$params$train$norm_data == TRUE) {
      predictions <- denormalize_predictions(predictions, control$data$vars$target_var, norm_params)
    }
  } else {
    stop("Invalid output_type specified in control.")
  }
  output_train$predictions <- predictions
  results$output_train <- output_train

  # Step 4.4: In-Processing (if defined)
  if (!is.null(control$engine_select$inprocessing)) {
    log_msg(paste0("[SINGLE] Running in-processing engine: ", control$engine_select$inprocessing), level = "info", control = control)
    control$params$inprocessing$protected_attributes <- control$data$vars$protected_vars
    control$params$inprocessing$target_var <- control$data$vars$target_var
    driver_in <- flowengineR_env$engines[[control$engine_select$inprocessing]]
    output_in <- driver_in(control, driver_train)
    
    if (control$settings$output_type == "prob") {
      predictions <- as.numeric(predict(output_in$adjusted_model, newdata = testdata, type = "prob"))
    } else if (control$settings$output_type == "response") {
      predictions <- as.numeric(predict(output_in$adjusted_model, newdata = testdata, type = "response"))
      if (control$params$train$norm_data == TRUE) {
        predictions <- denormalize_predictions(predictions, control$data$vars$target_var, norm_params)
      }
    } else {
      stop("Invalid output_type specified in control.")
    }
    output_in$predictions <- predictions
    results$output_inprocessing <- output_in
    log_msg("[SINGLE] In-processing completed.", level = "debug", control = control)
  }

  # Step 5: Post-Processing (if defined)
  if (!is.null(control$engine_select$postprocessing)) {
    log_msg(paste0("[SINGLE] Running post-processing engine: ", control$engine_select$postprocessing), level = "info", control = control)
    control$params$postprocessing$postprocessing_data <- cbind(
      predictions = as.numeric(predictions),
      actuals = testdata[[control$data$vars$target_var]],
      testdata[control$data$vars$protected_vars_binary]
    )
    control$params$postprocessing$protected_name <- control$data$vars$protected_vars_binary
    driver_post <- flowengineR_env$engines[[control$engine_select$postprocessing]]
    output_post <- driver_post(control)
    predictions <- as.numeric(output_post$adjusted_predictions)
    results$output_postprocessing <- output_post
    log_msg("[SINGLE] Post-processing completed.", level = "debug", control = control)
  }

  # Step 6: Evaluation (if defined)
  if (!is.null(control$engine_select$evaluation)) {
    log_msg("[SINGLE] Running evaluation step...", level = "info", control = control)
    control$params$evaluation$eval_data <- cbind(
      predictions = predictions,
      actuals = control$data$test$original[[control$data$vars$target_var]],
      control$data$test$original[control$data$vars$protected_vars_binary]
    )
    control$params$evaluation$protected_name <- control$data$vars$protected_vars_binary
    output_eval <- lapply(control$engine_select$evaluation, function(metric) {
      flowengineR_env$engines[[metric]](control)
    })
    names(output_eval) <- control$engine_select$evaluation
    results$output_eval <- output_eval
    log_msg("[SINGLE] Evaluation completed.", level = "debug", control = control)
  }

  if (isTRUE(control$params$train$norm_data)) {
    results$normalization <- list(
      params = norm_params,
      method = "minmax",
      based_on = "train_data",
      feature_names = c(control$data$vars$feature_vars, control$data$vars$protected_vars, control$data$vars$target_var)
    )
  }

  log_msg("[SINGLE] Workflow iteration completed. Returning results.", level = "info", control = control)
  return(results)
}
#--------------------------------------------------------------------