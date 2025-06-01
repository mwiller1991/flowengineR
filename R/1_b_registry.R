#--------------------------------------------------------------------
### Core Registration Function for Engines ###
#--------------------------------------------------------------------
#' Register an Engine in the fairnessToolbox Framework
#'
#' Dynamically loads, validates, and registers a new engine into the global `engines` registry.
#' This function is a central building block of the fairnessToolbox modular architecture, allowing
#' users to integrate custom engines for training, splitting, evaluation, fairness processing,
#' reporting, or execution.
#'
#' **Workflow:**
#' 1. Loads the engine file using `source()`.
#' 2. Expects the file to contain:
#'    - `wrapper_<engine_name>`: Standardized interface.
#'    - `engine_<engine_name>`: Core logic function.
#'    - `default_params_<engine_name>`: List of default hyperparameters.
#' 3. Calls a type-specific validation function, e.g., `validate_engine_train()`.
#' 4. If validation passes, the wrapper function is registered under `.GlobalEnv$engines`.
#'
#' **Supported Engine Types:**
#' - `split_*`: Splitter engines
#' - `execution_*`: Execution strategies (e.g., sequential, SLURM)
#' - `fairness_pre_*`: Fairness processing methods
#' - `train_*`: Training engines
#' - `fairness_in_*`: Fairness processing methods
#' - `fairness_post_*`: Fairness processing methods
#' - `eval_*`: Evaluation metrics
#' - `report_*`: Full report builders
#' - `reportelement_*`: Report element builders (tables, plots)
#' - `publish_*`: Publishing engines (e.g., PDF, HTML)
#'
#' **Validation Mechanism:**
#' A centralized validation function (e.g., `validate_engine_train()`) is automatically 
#' called by `register_engine()` based on the engine type. It checks structure, formal 
#' arguments, return types, and naming conventions.
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
#' @return Invisibly registers the engine into `.GlobalEnv$engines[[engine_name]]` if valid.
#' @export
register_engine <- function(engine_name, file_path) {
  tryCatch({
    # Derive engine type from the engine name
    engine_type <- strsplit(engine_name, "_")[[1]]
    
    if (engine_type[1] == "fairness") {
      full_engine_type <- paste(engine_type[1], engine_type[2], sep = "_")  # Combine "fairness" with "post", "pre", or "in"
    } else {
      full_engine_type <- engine_type[1]  # For other types like "train", "split", "report"
    }
    
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
    if (!exists(validate_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Validation function", validate_function_name, "not found for engine type:", full_engine_type))
    }
    
    # Get the functions
    wrapper_function <- get(wrapper_function_name, envir = .GlobalEnv)
    default_params_function <- get(default_params_function_name, envir = .GlobalEnv)
    validate_function <- get(validate_function_name, envir = .GlobalEnv)
    
    # Validate the engine
    validate_function(wrapper_function, default_params_function, engine_name)
    
    # Register the engine
    .GlobalEnv$engines[[engine_name]] <- wrapper_function
    message(paste("[SUCCESS] Engine registered successfully:", engine_name, "as type:", full_engine_type))
    message("---------------------------------------------------------------------------------------------")
    
  }, error = function(e) {
    warning(paste("[WARNING] Failed to register engine from file:", file_path, "->", e$message))
  })
}