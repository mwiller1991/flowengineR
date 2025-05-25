#--------------------------------------------------------------------
### training ###
#--------------------------------------------------------------------
#--------------------------------------------------------------------
#' Validate a Training Engine
#'
#' Validates a training engine by performing a dummy test run and ensuring required outputs are present.
#'
#' @param wrapper_function The wrapper function for the training engine.
#' @param default_params_function The function providing default hyperparameters for the engine.
#'
#' @return TRUE if the engine passes validation, otherwise an error is raised.
#' @export
validate_engine_train <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_train"
  )
  
  # --- functional check ---
  # Create dummy data
  dummy_data <- data.frame(
    x = rnorm(100),
    y = rnorm(100)
  )
  dummy_formula <- y ~ x
  
  # Create a dummy control object
  dummy_control <- list(
    params = list(
      train = controller_training(
        formula = dummy_formula,
        params = default_params_function()  # Use default hyperparameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  # Manually add `data` to the `train` list
  dummy_control$params$train$data$normalized <- dummy_data

  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Training engine validation failed:", e$message))
  })
  
  # Required fields for training engines
  required_fields <- c("model", "model_type", "formula")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Training engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  message("[SUCCESS] Training engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### fairness post-processing ###
#--------------------------------------------------------------------
#' Validate a Fairness Post-Processing Engine
#'
#' Validates a fairness post-processing engine by performing a dummy test run and ensuring required outputs are present.
#'
#' @param wrapper_function The wrapper function for the fairness post-processing engine.
#' @param default_params_function The function providing default parameters for the engine.
#'
#' @return TRUE if the engine passes validation, otherwise an error is raised.
#' @export
validate_engine_fairness_post <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_fairness_post"
  )
  
  # --- functional check ---
  # Create dummy data for predictions and actuals
  dummy_predictions <- rnorm(100, mean = 0.5, sd = 0.1)
  dummy_actuals <- rbinom(100, size = 1, prob = 0.5)
  dummy_protected_attributes <- data.frame(
    A1 = sample(c("A1_1", "A1_2"), 100, replace = TRUE),
    A2 = sample(c("A2_1", "A2_2", "A2_3"), 100, replace = TRUE)
  )
  
  # Create a dummy control object using the controller function
  dummy_control <- list(
    output_type = "prob",
    params = list(
      fairness_post = controller_fairness_post(
        protected_name = names(dummy_protected_attributes),
        params = default_params_function()  # Use default parameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  # Manually add `fairness_post_data` to the `fairness_post` list
  dummy_control$params$fairness_post$fairness_post_data <- cbind(
    predictions = as.numeric(dummy_predictions),
    actuals = dummy_actuals,
    dummy_protected_attributes
  )

  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Fairness post-processing engine validation failed:", e$message))
  })
  
  # Required fields for fairness post-processing engines
  required_fields <- c("adjusted_predictions", "method", "input_data", "protected_attributes")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Fairness post-processing engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check adjusted predictions
  if (!is.numeric(output$adjusted_predictions)) {
    stop("[WARNING] Adjusted predictions must be a numeric vector.")
  }
  
  # Check method
  if (!is.character(output$method) || length(output$method) != 1) {
    stop("[WARNING] Method must be a single character string.")
  }
  
  message("[SUCCESS] Fairness post-processing engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for fairness pre-processing ###
#--------------------------------------------------------------------
#' Validate a Fairness Pre-Processing Engine
#'
#' Validates a fairness pre-processing engine by performing a dummy test run and ensuring required outputs are present.
#'
#' @param wrapper_function The wrapper function for the fairness pre-processing engine.
#' @param default_params_function The function providing default parameters for the engine.
#'
#' @return TRUE if the engine passes validation, otherwise an error is raised.
#' @export
validate_engine_fairness_pre <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_pre"
  )
  
  # --- functional check ---
  # Create dummy data for protected attributes and target variable
  dummy_protected_attributes <- data.frame(
    A1 = sample(c("A1_1", "A1_2"), 100, replace = TRUE),
    A2 = sample(c("A2_1", "A2_2"), 100, replace = TRUE)
  )
  dummy_target_var <- rbinom(100, size = 1, prob = 0.5)
  dummy_data <- cbind(dummy_protected_attributes, target_var = dummy_target_var)
  
  # Create a dummy control object using the controller function
  dummy_control <- list(
    params = list(
      fairness_pre = controller_fairness_pre(
        protected_attributes = names(dummy_protected_attributes),
        target_var = "target_var",
        params = default_params_function()  # Use default parameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  
  # Manually add `fairness_post_data` to the `fairness_post` list
  dummy_control$params$fairness_pre$data <- dummy_data

  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Fairness pre-processing engine validation failed:", e$message))
  })
  
  # Required fields for fairness pre-processing engines
  required_fields <- c("preprocessed_data", "method")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Fairness pre-processing engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check transformed data
  if (!is.data.frame(output$preprocessed_data)) {
    stop("[WARNING] Preprocessed data must be a data frame.")
  }
  
  # Check method
  if (!is.character(output$method) || length(output$method) != 1) {
    stop("[WARNING] Method must be a single character string.")
  }
  
  message("[SUCCESS] Fairness pre-processing engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for fairness in-processing ###
#--------------------------------------------------------------------
#' Validate a Fairness In-Processing Engine
#'
#' Validates a fairness in-processing engine.
#'
#' @param wrapper_function The wrapper function for the fairness in-processing engine.
#' @param default_params_function The function providing default parameters for the engine.
#'
#' @return TRUE if the engine passes validation.
#' @export
validate_engine_fairness_in <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control", "driver_train"),
    expected_output_initializer = "initialize_output_fairness_in"
  )
  
  # --- functional check ---
  message("[INFO] Fairness in-processing engines do not support functional validation due to complexity.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for evaluation ###
#--------------------------------------------------------------------
#' Validate an Evaluation Engine
#'
#' Validates an evaluation engine by performing a dummy test run and ensuring required outputs are present.
#'
#' @param wrapper_function The wrapper function for the evaluation engine.
#' @param default_params_function The function providing default parameters for the engine.
#'
#' @return TRUE if the engine passes validation, otherwise an error is raised.
#' @export
validate_engine_eval <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_eval"
  )
  
  # --- functional check ---
  # Create dummy data for predictions and actuals
  dummy_predictions <- rnorm(100, mean = 0.5, sd = 0.1)
  dummy_actuals <- rbinom(100, size = 1, prob = 0.5)
  dummy_protected_attributes <- data.frame(
    A1 = sample(c("A1_1", "A1_2"), 100, replace = TRUE),  # Binär
    A2 = sample(c("A2_1", "A2_2"), 100, replace = TRUE)   # Binär
  )
  
  # Create a dummy control object using the controller function
  dummy_control <- list(
    output_type = "prob",
    params = list(
      eval = controller_evaluation(
        protected_name = names(dummy_protected_attributes),
        params = default_params_function()  # Use default parameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  # Manually add `eval_data` to the `eval` list
  dummy_control$params$eval$eval_data <- cbind(
    predictions = as.numeric(dummy_predictions),
    actuals = as.numeric(dummy_actuals),
    dummy_protected_attributes
  )
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Evaluation engine validation failed:", e$message))
  })
  
  # Required fields for evaluation engines
  required_fields <- c("metrics", "eval_type", "input_data")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Evaluation engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check metrics
  if (!is.list(output$metrics) || length(output$metrics) == 0) {
    stop("[WARNING] Metrics must be a non-empty list.")
  }
  
  # Check eval_type
  if (!is.character(output$eval_type) || length(output$eval_type) != 1) {
    stop("[WARNING] Eval_type must be a single character string.")
  }
  
  message("[SUCCESS] Evaluation engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for splitter ###
#--------------------------------------------------------------------
#' Validate a Splitter Engine
#'
#' Validates a splitter engine by performing a dummy test run and ensuring required outputs are present.
#' The special engine `split_userdefined` is skipped from validation, as it only channels user input.
#'
#' @param wrapper_function The wrapper function for the splitter engine.
#' @param default_params_function The function providing default parameters for the engine.
#'
#' @return TRUE if the engine passes validation, otherwise an error is raised.
#' @export
validate_engine_split <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_split"
  )
  
  # --- functional check ---
  # Create dummy dataset
  dummy_data <- data.frame(
    y = rbinom(100, 1, 0.5),
    x1 = rnorm(100),
    x2 = rnorm(100)
  )
  
  # Create dummy control object using controller function
  dummy_control <- list(
    data = list(full = dummy_data),
    params = list(
      split = controller_split(
        seed = 42,
        target_var = "y",
        params = default_params_function()
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Splitter engine validation failed:", e$message))
  })
  
  # Required fields for splitter engines
  required_fields <- c("split_type", "splits", "seed")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Splitter engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check that at least one split were created
  if (!is.list(output$splits) || length(output$splits) < 1) {
    stop("[WARNING] Splitter engine did not return a single splits.")
  }
  
  # Check structure of individual splits
  for (i in seq_along(output$splits)) {
    split <- output$splits[[i]]
    if (!all(c("train", "test") %in% names(split))) {
      stop(paste("[WARNING] Split", i, "is missing 'train' or 'test' components."))
    }
    if (!is.data.frame(split$train) || !is.data.frame(split$test)) {
      stop(paste("[WARNING] Split", i, "train/test components must be data frames."))
    }
  }
  
  message("[SUCCESS] Splitter engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for reportelement ###
#--------------------------------------------------------------------
#' Validate a Reportelement Engine (Structure Only)
#'
#' Validates a reportelement engine based on presence of required functions,
#' expected input signature, and output initialization call.
#'
#' @param wrapper_function The wrapper function.
#' @param default_params_function The default params function.
#'
#' @return TRUE if structure is valid, error otherwise.
#' @export
validate_engine_reportelement <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control", "workflow_results", "split_output", "alias"),
    expected_output_initializer = "initialize_output_reportelement"
  )
  
  message("[SUCCESS] Reportelement engine structure validated.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for report ###
#--------------------------------------------------------------------
#' Validate a Report Engine (Structure Only)
#'
#' Validates a report engine based on presence of required functions,
#' expected input signature, and output initialization call.
#'
#' @param wrapper_function The wrapper function.
#' @param default_params_function The default params function.
#' @param engine_name The name of the engine (without "wrapper_").
#'
#' @return TRUE if structure is valid, error otherwise.
#' @export
validate_engine_report <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control", "reportelements", "alias_report"),
    expected_output_initializer = "initialize_output_report"
  )
  
  message("[SUCCESS] Report engine structure validated.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for publish ###
#--------------------------------------------------------------------
#' Validate a Publish Engine (Structure Only)
#'
#' Validates a publish engine based on presence of required functions,
#' expected input signature, and output initialization call.
#'
#' @param wrapper_function The wrapper function.
#' @param default_params_function The default params function.
#' @param engine_name The name of the engine (without "wrapper_").
#'
#' @return TRUE if structure is valid, error otherwise.
#' @export
validate_engine_publish <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control", "object", "file_path", "alias_publish"),
    expected_output_initializer = "initialize_output_publish"
  )
  
  message("[SUCCESS] Publish engine structure validated.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for execution ###
#--------------------------------------------------------------------
#' Validate an Execution Engine (Structure Only)
#'
#' Validates an execution engine based on presence of required arguments
#' and expected output structure.
#'
#' @param wrapper_function The wrapper function.
#' @param default_params_function The default params function.
#' @param engine_name The name of the engine (without "wrapper_").
#'
#' @return TRUE if structure is valid, error otherwise.
#' @export
validate_engine_execution <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control", "split_output"),
    expected_output_initializer = "initialize_output_execution"
  )
  
  message("[SUCCESS] Execution engine structure validated.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for Workflow Resumption ###
#--------------------------------------------------------------------
#--------------------------------------------------------------------
#' Validate Resume Object for Workflow Resumption
#'
#' Ensures that the object passed to `resume_fairness_workflow()` contains
#' all required fields with correct types and structure.
#'
#' @param resume_object A list created via `controller_resume_execution()`.
#'
#' @return TRUE if structure is valid, otherwise throws an informative error.
#' @export
validate_resume_object <- function(resume_object) {
  if (!is.list(resume_object)) {
    stop("[Resume Validation] The resume object must be a list.")
  }
  
  # --- Check presence of required fields ---
  required_fields <- c("control", "split_output", "execution_output")
  missing_fields <- setdiff(required_fields, names(resume_object))
  if (length(missing_fields) > 0) {
    stop(sprintf("[Resume Validation] Missing required fields: %s", paste(missing_fields, collapse = ", ")))
  }
  
  # --- Check control structure ---
  control <- resume_object$control
  if (!is.list(control)) {
    stop("[Resume Validation] 'control' must be a list.")
  }
  
  # --- Check split_output structure ---
  split_output <- resume_object$split_output
  if (!is.list(split_output) || is.null(split_output$splits)) {
    stop("[Resume Validation] 'split_output' must be a list with a 'splits' element.")
  }
  if (!is.list(split_output$splits)) {
    stop("[Resume Validation] 'split_output$splits' must be a list.")
  }
  
  # --- Check execution_output structure ---
  exec <- resume_object$execution_output
  expected_exec_fields <- c("workflow_results", "execution_type", "continue_workflow")
  missing_exec <- setdiff(expected_exec_fields, names(exec))
  if (length(missing_exec) > 0) {
    stop(sprintf("[Resume Validation] 'execution_output' is missing required fields: %s", paste(missing_exec, collapse = ", ")))
  }
  
  # --- Check workflow_results ---
  if (!is.list(exec$workflow_results)) {
    stop("[Resume Validation] 'execution_output$workflow_results' must be a list of workflow results.")
  }
  
  return(TRUE)
}
#--------------------------------------------------------------------