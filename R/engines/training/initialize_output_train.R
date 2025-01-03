#--------------------------------------------------------------------
### helper for trainer-engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Training Engines
#'
#' @param model The trained model object.
#' @param model_type A string specifying the type of the model (e.g., "randomForest", "lm").
#' @param training_time The time taken to train the model, in seconds.
#' @param formula The formula used for training the model.
#' @param hyperparameters A list of hyperparameters used during training.
#' @param specific_output A list of model-specific optional outputs (default is NULL).
#' 
#' @return A list containing standardized output fields for the training engine.
#' @export
initialize_output_train <- function(model, model_type, formula, hyperparameters, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    model = model,
    model_type = model_type,
    formula = formula
  )
  
  # Add optional fields if provided
  if (!is.null(hyperparameters)) {
    output$hyperparameters <- hyperparameters
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------