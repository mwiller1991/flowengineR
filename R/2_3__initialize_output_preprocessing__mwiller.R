#--------------------------------------------------------------------
### Output Initializer: Preprocessing ###
#--------------------------------------------------------------------
#' Output Initializer: Preprocessing Results
#'
#' Creates a standardized output structure for preprocessing engines.
#' This ensures compatibility with downstream components in the flowengineR
#' framework and allows plug-and-play extension with new preprocessing methods.
#'
#' **Purpose:**
#' - Standardizes the format of preprocessed data returned by engines.
#' - Enables smooth integration into the processing and training pipeline.
#'
#' **Standardized Output:**
#' - `preprocessed_data`: Data frame with transformed features and/or target.
#' - `method`: String identifying the preprocessing method used.
#' - `params`: Optional list of parameters used for transformation.
#' - `specific_output`: Optional engine-specific details (e.g., transformation maps).
#'
#' **Usage Example (inside a preprocessing engine):**
#' ```r
#' initialize_output_preprocessing(
#'   preprocessed_data = transformed_df,
#'   method = "disparate_impact_remover",
#'   params = control$params$preprocessing$params,
#'   specific_output = list(transformation_map = map_info)
#' )
#' ```
#'
#' @param preprocessed_data A data.frame containing the transformed dataset.
#' @param method Character. Name of the preprocessing method applied.
#' @param params Optional. List of transformation parameters used.
#' @param specific_output Optional. Additional outputs or metadata for diagnostics.
#'
#' @return A standardized list to be returned by preprocessing engines.
#' @export
initialize_output_preprocessing <- function(preprocessed_data, method, params = NULL, specific_output = NULL) {
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