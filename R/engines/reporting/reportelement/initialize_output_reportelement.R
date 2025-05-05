#--------------------------------------------------------------------
### Helper for reportelement-engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Reportelement Engines
#'
#' Creates standardized output for individual reportelements.
#' Ensures consistency across all reportelement engines.
#'
#' **Standardized Output:**
#' - `type`: One of "table", "plot", "text", "interactive", etc.
#' - `content`: The main object (e.g., data.frame, ggplot, character string).
#' - `compatible_formats`: A character vector of supported formats (e.g., c("pdf", "html")).
#' - `input_data`: The raw data used to generate the reportelement (e.g., `aggregated_results`).
#' - `params`: Optional parameters used for this reportelement.
#' - `specific_output`: Optional method-specific additions (e.g., annotations, diagnostics).
#'
#' @param type The content type ("table", "plot", "text", ...).
#' @param content The actual reportelement object.
#' @param compatible_formats A character vector of supported formats.
#' @param input_data (Optional) The data used to generate the reportelement.
#' @param params (Optional) The parameters used during reportelement creation.
#' @param specific_output (Optional) Additional metadata or method-specific information.
#'
#' @return A standardized list containing the output fields.
#' @export
initialize_output_reportelement <- function(type, content, compatible_formats, input_data = NULL, params = NULL, specific_output = NULL) {
  # Base fields: Required for all reporting engines
  output <- list(
    type = type,
    content = content,
    compatible_formats = compatible_formats,
    input_data = input_data
  )
  
  # Optional fields
  if (!is.null(params)) {
    output$params <- params
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------