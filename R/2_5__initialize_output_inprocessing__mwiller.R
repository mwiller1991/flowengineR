#--------------------------------------------------------------------
### Output Initializer: In-Processing ###
#--------------------------------------------------------------------
#' Output Initializer: In-Processing Results
#'
#' Creates a standardized result object for in-processing engines
#' within the flowengineR workflow. This ensures a consistent output structure
#' across different training implementations.
#'
#' **Purpose:**
#' - Ensures compatibility with evaluation and reporting stages.
#' - Facilitates engine development and modular extension.
#'
#' **Standardized Output:**
#' - `adjusted_model`: The trained model after adjustment.
#' - `model_type`: A short string describing the model type (e.g., `"randomForest"`, `"glm"`).
#' - `predictions`: Optional numeric vector of model predictions (can be added externally).
#' - `params`: Optional list of engine-specific parameters used during training.
#' - `specific_output`: Optional method-specific results (e.g., adversary loss, weights).
#'
#' **Usage Example (inside a in-processing engine):**
#' ```r
#' initialize_output_inprocessing(
#'   adjusted_model = final_model,
#'   model_type = "randomForest",
#'   predictions = preds_after_adjustment,
#'   params = control$params$inprocessing$params,
#'   specific_output = list(adversary_accuracy = 0.67)
#' )
#' ```
#'
#' @param adjusted_model Trained model object after in-processing adjustments.
#' @param model_type Character. Model type identifier.
#' @param predictions Optional. Vector of predictions from the adjusted model.
#' @param params Optional. List of parameters used for in-processing.
#' @param specific_output Optional. Engine-specific diagnostics or metadata.
#'
#' @return A standardized list to be returned by in-processing engines.
#' @export
initialize_output_inprocessing <- function(adjusted_model, model_type, predictions = NULL, params = NULL, specific_output = NULL) {
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