#--------------------------------------------------------------------
### Subregistry Validation: Splitter Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Splitter Engines
#'
#' Internally validates any splitter engine during registration via `register_engine()`. 
#' Ensures that the wrapper adheres to expected structure, generates valid splits, 
#' and uses the standardized `initialize_output_split()` format.
#'
#' **Purpose:**
#' - Protects the framework from malformed or incomplete splitter engines.
#' - Ensures interoperability across engines and workflow steps.
#' - Enables automated integration of new splitter logic.
#'
#' **Validation Steps:**
#' 1. **Structural Check**  
#'    Uses `validate_engine_structure()` to confirm correct wrapper signature and output initializer.
#'
#' 2. **Functional Check**  
#'    Runs a dummy dataset through the engine to ensure:
#'    - At least one split is returned.
#'    - Each split includes both `train` and `test` components.
#'    - Split components are data frames.
#'
#' **Skipping Validation (Advanced Use):**
#' During development, wrappers may signal a skip by returning:
#' ```r
#' list(skip_validation = TRUE)
#' ```
#'
#' **Note:**  
#' The engine `"split_userdefined"` is excluded from structural validation,
#' as it simply forwards externally defined splits.
#'
#' **Usage:**  
#' Called automatically from `register_engine()` when registering `split_*` engines.
#'
#' @param wrapper_function Function. The wrapper function for the splitter engine.
#' @param default_params_function Function. Returns default parameters for the engine.
#' @param engine_name Character. Short name of the engine (e.g., `"split_random"`).
#'
#' @return TRUE if the engine is valid. Otherwise, an error is thrown.
#' @keywords internal
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
        params = default_params_function()
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  dummy_control$params$split$target_var <- "y"
  
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
### Subregistry Validation: Execution Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Execution Engines (Structure Only)
#'
#' Validates execution engines during registration via `register_engine()` 
#' by checking for correct wrapper structure and expected output format.
#'
#' **Purpose:**
#' - Ensures that the wrapper follows the standardized signature:
#'   - `function(control, split_output)`
#' - Verifies use of the correct output initializer: `initialize_output_execution()`
#' - Does **not** run the engine, as execution may be external or asynchronous.
#'
#' **Scope:**
#' - Applicable to all execution engines, including sequential, adaptive, or SLURM-based engines.
#'
#' **Usage:**
#' Called automatically from `register_engine()` when registering an `execution_*` engine.
#' Intended only for internal validation – not part of the public API.
#'
#' @param wrapper_function Function. The wrapper function for the execution engine.
#' @param default_params_function Function. Provides default parameters for the engine.
#' @param engine_name Character. Name of the engine (e.g., `"execution_slurm_array"`).
#'
#' @return TRUE if the structure is valid. Otherwise, an error is raised.
#' @keywords internal
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
### Subregistry Validation: Preprocessing Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Preprocessing Engines
#'
#' Validates preprocessing engines during registration via `register_engine()` 
#' by checking wrapper structure, expected output, and functional behavior.
#'
#' **Purpose:**
#' - Ensures that the wrapper function:
#'   - Has the correct signature: `function(control)`
#'   - Calls the correct initializer: `initialize_output_preprocessing()`
#' - Performs a functional test run using dummy data and default parameters.
#' - Verifies that required output fields are present and correctly structured.
#'
#' **Scope:**
#' - Applies to all engines prefixed with `preprocessing_`.
#' - Automatically triggered during `register_engine()`, unless explicitly skipped via internal flag.
#'
#' **Required Output Structure:**
#' - `preprocessed_data`: A data.frame with transformed input.
#' - `method`: A string identifier of the preprocessing method.
#'
#' **Usage Notes:**
#' - Wrapper may signal `skip_validation = TRUE` to bypass checks.
#' - If output fields are missing or invalid, an error is raised.
#'
#' @param wrapper_function Function. The wrapper function for the engine.
#' @param default_params_function Function. The engine’s default parameter provider.
#' @param engine_name Character. Name of the engine (e.g., `"preprocessing_resampling"`).
#'
#' @return TRUE if validation is successful, otherwise an error is raised.
#' @keywords internal
validate_engine_preprocessing <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_preprocessing"
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
      preprocessing = controller_preprocessing(
        params = default_params_function()  # Use default parameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  
  # Inject dummy data into control
  dummy_control$params$preprocessing$protected_attributes <- names(dummy_protected_attributes)
  dummy_control$params$preprocessing$target_var <- "target_var"
  dummy_control$params$preprocessing$data <- dummy_data
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Preprocessing engine validation failed:", e$message))
  })
  
  # Required fields
  required_fields <- c("preprocessed_data", "method")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Preprocessing engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check transformed data
  if (!is.data.frame(output$preprocessed_data)) {
    stop("[WARNING] Preprocessed data must be a data frame.")
  }
  
  # Check method
  if (!is.character(output$method) || length(output$method) != 1) {
    stop("[WARNING] Method must be a single character string.")
  }
  
  message("[SUCCESS] Preprocessing engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Subregistry Validation: Training Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Training Engines
#'
#' Validates training engines during registration via `register_engine()` by checking
#' wrapper structure, expected output format, and functional behavior using dummy data.
#'
#' **Purpose:**
#' - Ensures that the wrapper function:
#'   - Has the correct signature: `function(control)`
#'   - Calls the initializer: `initialize_output_train()`
#'   - Produces a complete and standardized training output.
#'
#' **Scope:**
#' - Applies to all engines of type `train_*`.
#' - Automatically triggered by `register_engine()` unless skipped using the internal flag.
#'
#' **Required Output Fields:**
#' - `model`: Trained model object.
#' - `model_type`: String identifier for the model type (e.g., `"randomForest"`, `"lm"`).
#' - `formula`: Formula used during training.
#'
#' **Usage Notes:**
#' - Wrapper may signal `skip_validation = TRUE` to skip validation (useful for meta-engines or testing).
#' - Uses dummy data and formula for execution test.
#' - Merges default parameters via the `default_params_function()`.
#'
#' @param wrapper_function Function. The wrapper function for the training engine.
#' @param default_params_function Function. Supplies default hyperparameters for the engine.
#' @param engine_name Character. Name of the engine being validated (e.g., `"train_rf"`).
#'
#' @return TRUE if the engine passes validation; otherwise, an error is raised.
#' @keywords internal
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
### Subregistry Validation: In-Processing Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for In-Processing Engines
#'
#' Validates in-processing engines during registration via `register_engine()`. 
#' Ensures structural consistency with the required interface and output format.
#'
#' **Purpose:**
#' - Confirms that the wrapper function:
#'   - Uses the correct argument signature: `function(control, driver_train)`
#'   - Calls the initializer: `initialize_output_inprocessing()`
#'   - Returns a valid in-processing output structure.
#'
#' **Scope:**
#' - Applies to all engines of type `inprocessing_*`.
#' - Triggered automatically by `register_engine()` unless validation is bypassed using an internal skip flag.
#'
#' **Note:**
#' - Functional validation (i.e., test run) is skipped due to the complexity of requiring a working training engine as input.
#' - Structural validation ensures interface consistency, enabling safe embedding into the modular workflow.
#'
#' @param wrapper_function Function. The wrapper function for the in-processing engine.
#' @param default_params_function Function. The function providing default parameters for the engine.
#' @param engine_name Character. The name of the engine being validated (e.g., `"inprocessing_weightedloss"`).
#'
#' @return TRUE if the engine passes structural validation; otherwise, an error is raised.
#' @keywords internal
validate_engine_inprocessing <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control", "driver_train"),
    expected_output_initializer = "initialize_output_inprocessing"
  )
  
  # --- functional check ---
  message("[INFO] In-processing engines do not support functional validation due to complexity.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Subregistry Validation: Post-Processing Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Post-Processing Engines
#'
#' Validates post-processing engines during registration via `register_engine()`. 
#' Ensures structural and functional compliance with the expected interface and output format.
#'
#' **Purpose:**
#' - Checks the wrapper function:
#'   - Accepts the correct argument signature: `function(control)`
#'   - Calls the initializer: `initialize_output_postprocessing()`
#'   - Produces a valid and complete post-processing output.
#'
#' **Scope:**
#' - Applies to all engines of type `postprocessing_*`.
#' - Triggered during `register_engine()` unless skipped via internal flag.
#'
#' **Required Output Fields:**
#' - `adjusted_predictions`: Numeric vector of modified predictions.
#' - `method`: Character string describing the applied technique.
#' - `input_data`: Data frame used for post-processing.
#' - `protected_attributes`: Data frame of protected group variables.
#'
#' **Usage Notes:**
#' - Dummy input includes predictions, actuals, and protected attributes.
#' - Engines may return `skip_validation = TRUE` to bypass validation (for example, in meta-engines).
#'
#' @param wrapper_function Function. The wrapper function for the post-processing engine.
#' @param default_params_function Function. Supplies default parameters for the engine.
#' @param engine_name Character. Name of the engine being validated (e.g., `"postprocessing_equalized_odds"`).
#'
#' @return TRUE if the engine passes validation; otherwise, an error is raised.
#' @keywords internal
validate_engine_postprocessing <- function(wrapper_function, default_params_function, engine_name) {
  # --- structural check ---
  validate_engine_structure(
    wrapper_function = wrapper_function,
    engine_name = engine_name,
    expected_args = c("control"),
    expected_output_initializer = "initialize_output_postprocessing"
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
    settings = list(
      output_type = "response"
      ),
    params = list(
      postprocessing = controller_postprocessing(
        params = default_params_function()  # Use default parameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  
  # Add postprocessing data manually
  dummy_control$params$postprocessing$postprocessing_data <- cbind(
    predictions = as.numeric(dummy_predictions),
    actuals = dummy_actuals,
    dummy_protected_attributes
  )
  dummy_control$params$postprocessing$protected_name <- names(dummy_protected_attributes)

  # Call the wrapper and validate the output
  output <- tryCatch({
    result <- wrapper_function(dummy_control)
    if (is.list(result) && isTRUE(result$skip_validation)) {
      message("[INFO] Skipping validation as signaled by wrapper.")
      return(TRUE)
    }
    result
  }, error = function(e) {
    stop(paste("[WARNING] Post-processing engine validation failed:", e$message))
  })
  
  # Required fields
  required_fields <- c("adjusted_predictions", "method", "input_data", "protected_attributes")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("[WARNING] Post-processing engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  if (!is.numeric(output$adjusted_predictions)) {
    stop("[WARNING] Adjusted predictions must be a numeric vector.")
  }
  
  if (!is.character(output$method) || length(output$method) != 1) {
    stop("[WARNING] Method must be a single character string.")
  }
  
  message("[SUCCESS] Post-processing engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### Subregistry Validation: Evaluation Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Evaluation Engines
#'
#' Validates evaluation engines during dynamic registration via `register_engine()`. 
#' This ensures structural correctness and functional reliability before embedding
#' the engine into the modular workflow system.
#'
#' **Purpose:**
#' - Confirms that the wrapper:
#'   - Accepts the expected argument signature: `function(control)`
#'   - Calls the appropriate output initializer: `initialize_output_eval()`
#'   - Returns a list with required fields: `metrics`, `eval_type`, and `input_data`
#'
#' **Scope:**
#' - Applies to all engines of type `eval_*`.
#' - Validation is triggered automatically unless bypassed via internal engine flag.
#'
#' **Functional Test:**
#' - Simulates a complete evaluation context with:
#'   - Synthetic predictions and labels
#'   - Dummy protected attributes (binary factors)
#'   - Default parameters via controller
#' - Confirms that required outputs are well-formed and consistent.
#'
#' **Common Validation Error Sources:**
#' - Missing field `metrics` or empty list
#' - `eval_type` not a character string
#' - Incorrect data format in returned `input_data`
#'
#' @param wrapper_function Function. The wrapper function for the evaluation engine.
#' @param default_params_function Function. Provides default parameters for the engine.
#' @param engine_name Character. Name of the engine being validated (e.g., `"eval_statisticalparity"`).
#'
#' @return TRUE if the engine passes structural and functional validation; error otherwise.
#' @keywords internal
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
    settings = list(
      output_type = "response"
      ),
    params = list(
      eval = controller_evaluation(
        params = default_params_function()  # Use default parameters
      )
    ),
    internal_skip_validation = TRUE  # internal flag for the wrapper to be able to jump the validation if neccessary
  )
  # Manually add `eval_data` to the `eval` list
  dummy_control$params$evaluation$eval_data <- cbind(
    predictions = as.numeric(dummy_predictions),
    actuals = as.numeric(dummy_actuals),
    dummy_protected_attributes
  )
  
  dummy_control$params$evaluation$protected_name <- names(dummy_protected_attributes)
    
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
### Subregistry Validation: Reportelement Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Reportelement Engines
#'
#' Validates reportelement engines during dynamic registration via `register_engine()`.
#' Ensures that the engine adheres to the standardized interface and returns
#' output in the expected structure using `initialize_output_reportelement()`.
#'
#' **Purpose:**
#' - Confirms structural compatibility of engines with the flowengineR reporting layer.
#' - Allows seamless composition of reports from validated reportelements.
#'
#' **Validation Criteria:**
#' - Wrapper must accept the following arguments:
#'   - `control`: Workflow control object.
#'   - `workflow_results`: Results from training and evaluation.
#'   - `split_output`: Output from splitter engine.
#'   - `alias`: Identifier for the reportelement.
#' - Wrapper must call `initialize_output_reportelement()`.
#' - No functional test is performed, as the output content is engine-specific and diverse.
#'
#' **When to Use:**
#' - Automatically triggered by `register_engine()` if an engine name starts with `reportelement_`.
#' - Can also be called manually to pre-check engines before registration.
#'
#' @param wrapper_function Function. The wrapper function for the reportelement engine.
#' @param default_params_function Function. Provides default parameters for the engine.
#' @param engine_name Character. Name of the engine being validated (e.g., `"reportelement_boxplot_predictions"`).
#'
#' @return TRUE if the engine passes structural validation; otherwise an error is raised.
#' @keywords internal
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
### Subregistry Validation: Report Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Report Engines
#'
#' Validates report engines during dynamic registration via `register_engine()`.
#' Ensures that the report engine adheres to the standardized input interface and 
#' produces output using `initialize_output_report()`.
#'
#' **Purpose:**
#' - Ensures structural compatibility with the reporting architecture of the framework.
#' - Allows validated reports to be composed and passed to publishing engines.
#'
#' **Validation Criteria:**
#' - Wrapper must accept the following arguments:
#'   - `control`: Workflow control object.
#'   - `reportelements`: List of prepared reportelements.
#'   - `alias_report`: Unique identifier of the report.
#' - Wrapper must call `initialize_output_report()`.
#' - No functional validation is performed, as reports are structured compositions.
#'
#' **When to Use:**
#' - Automatically triggered during `register_engine()` for any `report_*` engine.
#' - Can also be run manually before registration to pre-test structural conformity.
#'
#' @param wrapper_function Function. The wrapper function for the report engine.
#' @param default_params_function Function. Provides default parameters for the engine.
#' @param engine_name Character. Name of the engine being validated (e.g., `"report_modelcomparison"`).
#'
#' @return TRUE if the engine passes structural validation; otherwise an error is raised.
#' @keywords internal
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
### Subregistry Validation: Publish Engines ###
#--------------------------------------------------------------------
#' Subregistry Validation for Publish Engines
#'
#' Validates publish engines during dynamic registration via `register_engine()`.
#' Ensures that the publish engine adheres to the standardized input interface and 
#' produces output using `initialize_output_publish()`.
#'
#' **Purpose:**
#' - Ensures compatibility with the publishing architecture of the framework.
#' - Guarantees that publish engines follow the required structure for writing files.
#'
#' **Validation Criteria:**
#' - Wrapper must accept the following arguments:
#'   - `control`: The full workflow control object.
#'   - `object`: The object to be published (either a report or a reportelement).
#'   - `file_path`: Output path for saving the file.
#'   - `alias_publish`: Identifier string used for referencing the publish object.
#' - Wrapper must call `initialize_output_publish()` to return standardized output.
#' - No functional validation is performed (structure-only check).
#'
#' **When to Use:**
#' - Automatically triggered during `register_engine()` for any `publish_*` engine.
#' - Can also be called manually for pre-testing new publishing engines.
#'
#' @param wrapper_function Function. The wrapper function for the publish engine.
#' @param default_params_function Function. The default parameter function for the engine.
#' @param engine_name Character. Name of the engine being validated (e.g., `"publish_pdf"`).
#'
#' @return TRUE if the engine passes structural validation; otherwise an error is raised.
#' @keywords internal
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
### Validation for Workflow Resumption ###
#--------------------------------------------------------------------
#' Validate Resume Object for Workflow Resumption
#'
#' Ensures that the object passed to `resume_workflow()` contains
#' all required fields with the correct structure and types. This check is 
#' critical to prevent runtime errors when resuming SLURM-based or 
#' externally executed workflows.
#'
#' **Expected Structure:**
#' The resume object must be a list with the following fields:
#' - `control`: The full control object as used in the original workflow.
#' - `split_output`: A list of generated data splits, created by a splitter engine.
#' - `execution_output`: A list containing execution metadata and split results.
#'
#' Within `execution_output`, the following fields are mandatory:
#' - `workflow_results`: A list of outputs from each split, named identically to `split_output$splits`.
#' - `execution_type`: Character string describing the execution method (e.g., `"slurm_array"`).
#' - `continue_workflow`: Logical flag controlling whether remaining steps should execute automatically.
#'
#' **Usage Note:**
#' Use this function after calling `controller_resume_execution()` or any custom SLURM resumption routine.
#'
#' @param resume_object A list object created via `controller_resume_execution()`.
#'
#' @return Returns `TRUE` if validation is successful; otherwise throws a descriptive error.
#' @keywords internal
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