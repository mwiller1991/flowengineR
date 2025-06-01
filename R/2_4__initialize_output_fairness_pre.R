#--------------------------------------------------------------------
### Output Initializer: Fairness Pre-Processing ###
#--------------------------------------------------------------------
#' Output Initializer: Fairness Pre-Processing Results
#'
#' Creates a standardized output structure for fairness pre-processing engines.
#' This ensures compatibility with downstream components in the fairnessToolbox
#' and allows plug-and-play extension with new preprocessing methods.
#'
#' **Purpose:**
#' - Standardizes the format of preprocessed data returned by fairness engines.
#' - Enables smooth integration into the training pipeline.
#'
#' **Standardized Output:**
#' - `preprocessed_data`: Data frame with transformed features and/or target.
#' - `method`: String identifying the pre-processing method used.
#' - `params`: Optional list of parameters used for transformation.
#' - `specific_output`: Optional engine-specific details (e.g., transformation maps).
#'
#' **Usage Example (inside a fairness pre-processing engine):**
#' ```r
#' initialize_output_pre(
#'   preprocessed_data = transformed_df,
#'   method = "disparate_impact_remover",
#'   params = control$params$fairness_pre$params,
#'   specific_output = list(transformation_map = map_info)
#' )
#' ```
#'
#' @param preprocessed_data A data.frame containing the transformed dataset.
#' @param method Character. Name of the fairness pre-processing method applied.
#' @param params Optional. List of transformation parameters used.
#' @param specific_output Optional. Additional outputs or metadata for diagnostics.
#'
#' @return A standardized list to be returned by pre-processing engines.
#' @export
initialize_output_pre <- function(preprocessed_data, method, params = NULL, specific_output = NULL) {
  # Base fields: Required for all engines
  output <- list(
    preprocessed_data = preprocessed_data,
    method = method
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