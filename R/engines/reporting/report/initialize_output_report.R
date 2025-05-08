#--------------------------------------------------------------------
### Helper: Initialize Output for Reports ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Full Report
#'
#' Creates standardized report output for use with publishing engines.
#'
#' @param report_title A string indicating the display title of the report.
#' @param report_type A string defining the report's internal semantic type.
#' @param compatible_formats A character vector of supported export formats.
#' @param sections A list of report sections (each with heading and content).
#' @param params Optional list of parameter inputs.
#' @param specific_output Optional list of engine-specific metadata.
#'
#' @return A structured report list.
#' @export
initialize_output_report <- function(report_title, report_type, compatible_formats, sections, params = NULL, specific_output = NULL) {
  # Base fields: Required for all reporting engines 
  output <- list(
    report_title = report_title,
    report_type = report_type,
    compatible_formats = compatible_formats,
    sections = sections
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