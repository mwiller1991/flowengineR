#--------------------------------------------------------------------
### Output Initializer: Full Report ###
#--------------------------------------------------------------------
#' Output Initializer: Full Report Object
#'
#' Creates a structured report object to be used by publishing engines within the flowengineR.
#' Ensures consistent formatting and metadata across all full reports, whether user-defined or
#' programmatically assembled from reportelements.
#'
#' **Purpose:**
#' - Provides a standardized representation of full reports.
#' - Enables compatibility with multiple export formats and publishing engines.
#'
#' **Standardized Output:**
#' - `report_title`: Title for display and export.
#' - `report_type`: Internal semantic type (e.g., `"summary_report"` or `"single_element"`).
#' - `compatible_formats`: Character vector of allowed export formats (e.g., `c("pdf", "html")`).
#' - `sections`: A list where each section has a `heading` and `content` list.
#' - `params`: Optional list of user-defined or engine-provided parameters.
#' - `specific_output`: Optional metadata such as rendering time or template hints.
#'
#' **Usage Example (inside a report engine):**
#' ```r
#' initialize_output_report(
#'   report_title = "Model Summary Report",
#'   report_type = "summary_report",
#'   compatible_formats = c("pdf", "html"),
#'   sections = list(
#'     list(
#'       heading = "Performance Overview",
#'       content = list(object1, object2)
#'     )
#'   ),
#'   params = control$params$report$params[["summary"]],
#'   specific_output = list(rendered_sections = 1)
#' )
#' ```
#'
#' @param report_title Character. The display title of the report.
#' @param report_type Character. A semantic identifier (e.g., `"summary_report"`, `"model_diagnostics"`).
#' @param compatible_formats Character vector. List of supported export formats.
#' @param sections List. Each element should be a list with `heading` and `content`.
#' @param params Optional list. Parameters used to generate the report.
#' @param specific_output Optional list. Additional metadata for reporting engines.
#'
#' @return A structured list representing a complete report.
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