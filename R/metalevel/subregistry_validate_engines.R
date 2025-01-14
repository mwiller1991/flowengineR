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
validate_engine_train <- function(wrapper_function, default_params_function) {
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
    )
  )
  # Manually add `data` to the `train` list
  dummy_control$params$train$data <- dummy_data
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    wrapper_function(dummy_control)
  }, error = function(e) {
    stop(paste("Training engine validation failed:", e$message))
  })
  
  # Required fields for training engines
  required_fields <- c("model", "model_type", "formula")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("Training engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  message("Training engine validated successfully.")
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
validate_engine_fairness_post <- function(wrapper_function, default_params_function) {
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
        params = NULL #default_params_function()  # Use default parameters
      )
    )
  )
  # Manually add `fairness_post_data` to the `fairness_post` list
  dummy_control$params$fairness_post$fairness_post_data <- cbind(
    predictions = as.numeric(dummy_predictions),
    actuals = dummy_actuals,
    dummy_protected_attributes
  )
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    wrapper_function(dummy_control)
  }, error = function(e) {
    stop(paste("Fairness post-processing engine validation failed:", e$message))
  })
  
  # Required fields for fairness post-processing engines
  required_fields <- c("adjusted_predictions", "method", "input_data", "protected_attributes")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("Fairness post-processing engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check adjusted predictions
  if (!is.numeric(output$adjusted_predictions)) {
    stop("Adjusted predictions must be a numeric vector.")
  }
  
  # Check method
  if (!is.character(output$method) || length(output$method) != 1) {
    stop("Method must be a single character string.")
  }
  
  message("Fairness post-processing engine validated successfully.")
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
validate_engine_fairness_pre <- function(wrapper_function, default_params_function) {
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
        params = NULL #default_params_function()  # Use default parameters
      )
    )
  )
  
  # Manually add `fairness_post_data` to the `fairness_post` list
  dummy_control$params$fairness_pre$data <- dummy_data
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    wrapper_function(dummy_control)
  }, error = function(e) {
    stop(paste("Fairness pre-processing engine validation failed:", e$message))
  })
  
  # Required fields for fairness pre-processing engines
  required_fields <- c("preprocessed_data", "method")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("Fairness pre-processing engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check transformed data
  if (!is.data.frame(output$preprocessed_data)) {
    stop("Preprocessed data must be a data frame.")
  }
  
  # Check method
  if (!is.character(output$method) || length(output$method) != 1) {
    stop("Method must be a single character string.")
  }
  
  message("Fairness pre-processing engine validated successfully.")
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
validate_engine_fairness_in <- function(wrapper_function, default_params_function) {
  message("Fairness in-processing engine validation passed (Dummy).")
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
validate_engine_eval <- function(wrapper_function, default_params_function) {
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
        params = NULL #default_params_function()  # Use default parameters
      )
    )
  )
  # Manually add `eval_data` to the `eval` list
  dummy_control$params$eval$eval_data <- cbind(
    predictions = as.numeric(dummy_predictions),
    actuals = as.numeric(dummy_actuals),
    dummy_protected_attributes
  )
  
  # Call the wrapper and validate the output
  output <- tryCatch({
    wrapper_function(dummy_control)
  }, error = function(e) {
    stop(paste("Evaluation engine validation failed:", e$message))
  })
  
  # Required fields for evaluation engines
  required_fields <- c("metrics", "eval_type", "input_data")
  missing_fields <- setdiff(required_fields, names(output))
  if (length(missing_fields) > 0) {
    stop(paste("Evaluation engine output missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  # Check metrics
  if (!is.list(output$metrics) || length(output$metrics) == 0) {
    stop("Metrics must be a non-empty list.")
  }
  
  # Check eval_type
  if (!is.character(output$eval_type) || length(output$eval_type) != 1) {
    stop("Eval_type must be a single character string.")
  }
  
  message("Evaluation engine validated successfully.")
  return(TRUE)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### validation for splitter ###
#--------------------------------------------------------------------
#' Validate a Splitter Engine
#'
#' Validates a splitter engine.
#'
#' @param wrapper_function The wrapper function for the splitter engine.
#' @param default_params_function The function providing default parameters for the engine.
#'
#' @return TRUE if the engine passes validation.
#' @export
validate_engine_split <- function(wrapper_function, default_params_function) {
  message("Splitter engine validation passed (Dummy).")
  return(TRUE)
}
#--------------------------------------------------------------------