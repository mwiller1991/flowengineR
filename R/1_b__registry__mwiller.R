#--------------------------------------------------------------------
### Core Registration Function for Engines ###
#--------------------------------------------------------------------
#' Register an Engine in the flowengineR Framework
#'
#' Dynamically loads, validates, and registers a new engine into the global `engines` registry.
#' This function is a central building block of the `flowengineR` modular architecture, allowing
#' users to integrate custom engines for preprocessing, training, postprocessing, evaluation,
#' reporting, publishing, and execution.
#'
#' **Workflow:**
#' 1. Loads the engine file using `source()`.
#' 2. Expects the file to contain:
#'    - `wrapper_<engine_name>`: Standardized interface
#'    - `engine_<engine_name>`: Core logic function
#'    - `default_params_<engine_name>`: List of default hyperparameters
#' 3. Calls a type-specific validation function, e.g., `validate_engine_train()`
#' 4. If validation passes, the wrapper function is registered under `flowengineR_env$engines`
#'
#' **Supported Engine Types:**
#' - `split_*`: Data splitting engines
#' - `execution_*`: Workflow execution strategies (e.g., sequential, parallel)
#' - `preprocessing_*`: Data preprocessing before training
#' - `train_*`: Model training engines
#' - `inprocessing_*`: In-training modification engines
#' - `postprocessing_*`: Prediction adjustment after training
#' - `eval_*`: Evaluation engines (metrics, diagnostics)
#' - `report_*`: Report builders
#' - `reportelement_*`: Visual or tabular reporting components
#' - `publish_*`: Export engines for external output
#'
#' **Validation Mechanism:**
#' A centralized validation function (e.g., `validate_engine_train()`) is automatically 
#' called based on the engine type. It checks structure, required arguments, return types,
#' and naming conventions.
#'
#' **Skipping Validation (Advanced Use):**
#' Wrappers can opt out of validation (e.g., during prototyping) by returning
#' `list(skip_validation = TRUE)` during test execution.
#'
#' **Example:**
#' ```r
#' register_engine(
#'   engine_name = "train_customtree",
#'   file_path = "engines/train/train_customtree.R"
#' )
#' ```
#'
#' @param engine_name Character. Name of the engine, e.g., `"train_lm"`.
#' @param file_path Character. Path to the R script that defines the engine components.
#'
#' @return Invisibly registers the engine into `flowengineR_env$engines[[engine_name]]` if valid.
#' @export
register_engine <- function(engine_name, file_path) {
  tryCatch({
    full_engine_type <- strsplit(engine_name, "_")[[1]][1]
    
    # Source the engine file
    source(file_path, local = FALSE)
    
    # Dynamically construct function names
    wrapper_function_name <- paste0("wrapper_", engine_name)
    engine_function_name <- paste0("engine_", engine_name)
    default_params_function_name <- paste0("default_params_", engine_name)
    validate_function_name <- paste0("validate_engine_", full_engine_type)
    
    # Check if all required functions exist
    if (!exists(engine_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Engine function", engine_function_name, "not found in file:", file_path))
    }
    if (!exists(wrapper_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Wrapper function", wrapper_function_name, "not found in file:", file_path))
    }
    if (!exists(default_params_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Default params function", default_params_function_name, "not found in file:", file_path))
    }
    if (!exists(validate_function_name, mode = "function", envir = asNamespace("flowengineR"))) {
      stop(paste("Validation function", validate_function_name, "not found for engine type:", full_engine_type))
    }
    
    # Get the functions
    wrapper_function <- get(wrapper_function_name, envir = .GlobalEnv)
    default_params_function <- get(default_params_function_name, envir = .GlobalEnv)
    validate_function <- get(validate_function_name, mode = "function", envir = parent.env(environment()))
    
    # Validate the engine
    validate_function(wrapper_function, default_params_function, engine_name)
    
    # Register the engine
    flowengineR_env$engines[[engine_name]] <- wrapper_function
    message(paste("[SUCCESS] Engine registered successfully:", engine_name, "as type:", full_engine_type))
    message("---------------------------------------------------------------------------------------------")
    
  }, error = function(e) {
    warning(paste("[WARNING] Failed to register engine from file:", file_path, "->", e$message))
  })
}