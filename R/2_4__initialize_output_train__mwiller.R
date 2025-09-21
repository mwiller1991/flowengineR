#--------------------------------------------------------------------
### Output Initializer: Training Engine ###
#--------------------------------------------------------------------
#' Output Initializer: Training Engine Results
#'
#' Creates a standardized output object for **training engines** within the flowengineR
#' This function ensures that all training engines return results in a uniform structure,
#' enabling downstream components (e.g., postprocessing, evaluation, reporting) to function
#' independently of the specific model used.
#'
#' **Purpose:**
#' - Enforces a consistent interface between training engines and the workflow.
#'
#' **Standardized Output:**
#' - `model`: The trained model object (e.g., a `gbm`, `lm`, or caret model).
#' - `model_type`: A string identifying the model type (e.g., `"gbm"`).
#' - `formula`: The formula used for training (e.g., `target ~ .`).
#' - `predictions`: filled externally by the workflow after prediction.
#' - `hyperparameters`: Optional list of hyperparameters used during training.
#' - `specific_output`: Optional list of additional engine-specific outputs (e.g., feature importances).
#'
#' **Usage Example (inside an engine):**
#' ```r
#' model <- gbm:gbm(formula = control$params$train$formula, data = control$params$train$data)
#' hyperparams <- merge_with_defaults(control$params$train$params, default_params_train_gbm())
#' initialize_output_train(
#'   model = model,
#'   model_type = "gbm",
#'   formula = control$params$train$formula,
#'   hyperparameters = hyperparams,
#'   specific_output = list(feature_importance = model$importance)
#' )
#' ```
#'
#' @param model Trained model object returned by the engine.
#' @param model_type Character string describing the model type (e.g., `"lm"`, `"gbm"`).
#' @param formula Formula used for training (e.g., `target ~ .`).
#' @param predictions (Optional) Numeric vector of predictions. Should be filled **after** training in the workflow.
#' @param hyperparameters (Optional) Named list of hyperparameters used for training.
#' @param specific_output (Optional) List of engine-specific additional outputs.
#'
#' @return A named list with standardized training results for the workflow.
#' @export
initialize_output_train <- function(model, model_type, formula, predictions = NULL, hyperparameters = NULL, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    model = model,
    model_type = model_type,
    formula = formula,
    predictions = predictions
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