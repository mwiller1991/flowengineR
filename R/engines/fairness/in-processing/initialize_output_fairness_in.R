#--------------------------------------------------------------------
### helper for trainer-engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Training Engines
#'
#' Creates standardized output for training engines. 
#' Ensures consistency across all training engines.
#'
#' **Standardized Output:**
#' - `model`: The trained model object.
#' - `model_type`: A string specifying the type of the model (e.g., "randomForest", "lm").
#' - `formula`: The formula used for training the model.
#' - `predictions`: Numeric vector of predictions, not to be filled by the engine (but the metalevel).
#' - `hyperparameters`: A list of hyperparameters used during training.
#' - `specific_output`: Optional engine-specific outputs.
#'
#' @param model The trained model object.
#' @param model_type A string specifying the type of the model (e.g., "randomForest", "lm").
#' @param formula The formula used for training the model.
#' @param predictions Numeric vector of predictions, not to be filled by the engine (but the metalevel).
#' @param hyperparameters A list of hyperparameters used during training.
#' @param specific_output A list of model-specific optional outputs (default is NULL).
#'
#' @return A standardized list containing the output fields for the training engine.
#' @export
initialize_output_fairness_in <- function(adjusted_model, model_type, predictions = NULL, params = NULL, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    adjusted_model = adjusted_model,
    model_type = model_type,
    predictions = predictions
  )
  
  # Add optional fields if provided
  if (!is.null(params)) {
    output$params <- params
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------