#--------------------------------------------------------------------
### training ###
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