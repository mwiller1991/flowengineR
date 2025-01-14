#--------------------------------------------------------------------
### Helper for Pre-Processing Engines ###
#--------------------------------------------------------------------
#' Initialize Output for Pre-Processing Engines
#'
#' Creates standardized output for Pre-Processing Engines.
#' Ensures consistency across all engines of this type.
#'
#' **Standardized Output:**
#' - `preprocessed_data`: Data frame of transformed data.
#' - `method`: Character string describing the pre-processing method.
#' - `params`: Parameters used for the transformation.
#' - `specific_output`: Optional engine-specific outputs.
#'
#' @param preprocessed_data Data frame of transformed data.
#' @param method Character string describing the pre-processing method.
#' @param params Parameters used for the transformation (default is NULL).
#' @param specific_output Optional engine-specific outputs (default is NULL).
#'
#' @return A standardized list containing the output fields.
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