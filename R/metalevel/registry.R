#--------------------------------------------------------------------
### registry for engines ###
#--------------------------------------------------------------------
#--------------------------------------------------------------------
#' Register an Engine
#'
#' Registers an engine by sourcing its file, validating it, and adding it to the global registry.
#' The function dynamically derives wrapper, default hyperparameters, and validation functions based on the file name.
#'
#' @param engine_name The name of the engine (e.g., "train_lm").
#' @param file_path The file path to the engine definition.
#'
#' @return Registers the engine in the global registry if validation passes.
#' @export
register_engine <- function(engine_name, file_path) {
  tryCatch({
    # Derive engine type from the engine name
    engine_type <- strsplit("train_lm", "_")[[1]][1]  # Extract "train", "split", etc.
    
    # Source the engine file
    source(file_path, local = FALSE)
    
    # Dynamically construct function names
    wrapper_function_name <- paste0("wrapper_", engine_name)
    engine_function_name <- paste0("engine_", engine_name)
    default_hyperparameters_function_name <- paste0("default_hyperparameters_", engine_name)
    validate_function_name <- paste0("validate_engine_", engine_type)
    
    # Check if all required functions exist
    if (!exists(engine_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Engine function", engine_function_name, "not found in file:", file_path))
    }
    if (!exists(wrapper_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Wrapper function", wrapper_function_name, "not found in file:", file_path))
    }
    if (!exists(default_hyperparameters_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Default hyperparameters function", default_hyperparameters_function_name, "not found in file:", file_path))
    }
    if (!exists(validate_function_name, mode = "function", envir = .GlobalEnv)) {
      stop(paste("Validation function", validate_function_name, "not found for engine type:", engine_type))
    }
    
    # Get the functions
    wrapper_function <- get(wrapper_function_name, envir = .GlobalEnv)
    default_hyperparameters_function <- get(default_hyperparameters_function_name, envir = .GlobalEnv)
    validate_function <- get(validate_function_name, envir = .GlobalEnv)
    
    # Validate the engine
    validate_function(wrapper_function, default_hyperparameters_function)
    
    # Register the engine
    engines[[engine_name]] <- wrapper_function
    message(paste("Engine registered successfully:", engine_name, "as type:", engine_type))
    
  }, error = function(e) {
    warning(paste("Failed to register engine from file:", file_path, "->", e$message))
  })
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validate-function for training-engines ###
#--------------------------------------------------------------------
#--------------------------------------------------------------------
#' Validate a Training Engine
#'
#' Validates a training engine by performing a dummy test run and ensuring required outputs are present.
#'
#' @param wrapper_function The wrapper function for the training engine.
#' @param default_hyperparameters_function The function providing default hyperparameters for the engine.
#'
#' @return TRUE if the engine passes validation, otherwise an error is raised.
#' @export
validate_engine_train <- function(wrapper_function, default_hyperparameters_function) {
  # Create dummy data
  dummy_data <- data.frame(
    x = rnorm(100),
    y = rnorm(100)
  )
  dummy_formula <- y ~ x
  
  # Create a dummy control object
  dummy_control <- list(
    params = list(
      train = list(
        formula = dummy_formula,
        data = dummy_data,
        hyperparameters = default_hyperparameters_function()  # Use default hyperparameters
      )
    )
  )
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    wrapper_function(dummy_control)
  }, error = function(e) {
    stop(paste("Training engine validation failed:", e$message))
  })
  
  # Required fields for training engines
  required_fields <- c("model", "model_type", "training_time", "formula")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("Training engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check training time
  if (!is.numeric(output$training_time) || output$training_time <= 0) {
    stop("Training time is either missing or not valid (must be a positive number).")
  }
  
  message("Training engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### load preinstalled package-engines ###
#--------------------------------------------------------------------
# Load preinstalled Train-Engines 
register_engine("train_lm", "~/fairness_toolbox/R/engines/training/engine_train_lm.R")

# Load preinstalled Fairness-Engines 
register_engine("fairness_pre_method1", "~/fairness_toolbox/R/engines/fairness/pre-processing/engine_fairness_pre_method1.R")
register_engine("fairness_post_genresidual", "~/fairness_toolbox/R/engines/fairness/post-processing/engine_fairness_post_genresidual.R")

# Load preinstalled Evaluation-Engines
register_engine("eval_summarystats", "~/fairness_toolbox/R/engines/evaluation/general/engine_eval_summarystats.R")
register_engine("eval_mse", "~/fairness_toolbox/R/engines/evaluation/precision/engine_eval_mse.R")
register_engine("eval_statisticalparity", "~/fairness_toolbox/R/engines/evaluation/fairness/engine_eval_statisticalparity.R")

# Load new Splitter-Engines
register_engine("split_random", "~/fairness_toolbox/R/engines/split/engine_split_random.R")
register_engine("split_cv", "~/fairness_toolbox/R/engines/split/engine_split_cv.R")

# Debugging: List registered engines
print(names(engines))
#--------------------------------------------------------------------