#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Publishing Engine: Export Report to Excel
#'
#' Writes a structured report object to an Excel file (.xlsx) using the `openxlsx` package.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `report`: A structured report object (created via `initialize_output_report()`).
#' - `file_path`: File path where the Excel file should be saved (without extension).
#' - `params`: Optional list of engine-specific parameters (not used in this engine).
#'
#' **Output (returned to wrapper):**
#' - A character string with the path to the successfully created `.xlsx` file.
#'
#' @seealso [wrapper_publish_excel_basis()]
#'
#' @param report A standardized report object.
#' @param file_path Output file path (without extension).
#' @param params Optional publishing parameters.
#'
#' @return Path to created Excel file.
#' @keywords internal
engine_publish_excel_basis <- function(report, file_path, params = NULL) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Package 'openxlsx' is required for Excel publishing.")
  }
  
  wb <- openxlsx::createWorkbook()
  
  for (section in report$sections) {
    sheet_name <- gsub("[^A-Za-z0-9]", "_", substr(section$heading, 1, 30))  # Excel-safe sheet name
    
    openxlsx::addWorksheet(wb, sheet_name)
    
    row <- 1
    for (element in section$content) {
      if (element$type == "text" || element$type == "text_warning") {
        openxlsx::writeData(wb, sheet = sheet_name, x = element$content, startRow = row)
        row <- row + 2
      } else if (element$type == "table") {
        openxlsx::writeData(wb, sheet = sheet_name, x = element$content, startRow = row)
        row <- row + nrow(element$content) + 2
      } else {
        openxlsx::writeData(wb, sheet = sheet_name, x = paste("Element of type", element$type, "not supported."), startRow = row)
        row <- row + 2
      }
    }
  }
  
  final_path <- paste0(file_path, ".xlsx")
  openxlsx::saveWorkbook(wb, final_path, overwrite = TRUE)
  return(normalizePath(final_path))
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Publishing Engine: Excel Export
#'
#' Validates and prepares standardized inputs, checks format compatibility,
#' and invokes the Excel publishing engine. Returns standardized output using `initialize_output_publish()`.
#'
#' **Standardized Inputs:**
#' - `control$params$publish$params[[alias_publish]]`: Named list of engine-specific parameters (optional).
#' - `object`: A structured report or reportelement object.
#' - `file_path`: Base file path (without extension) where the Excel file will be saved.
#' - `alias_publish`: Character string identifying this publishing instance.
#'
#' **Engine-Specific Parameters (`control$params$publish$params[[alias_publish]]`):**
#' - `obj_type` *(character)*: Must be `"report"` or `"reportelement"` (required).
#' - *(no other parameters used in this engine)*
#'
#' **Example Template Snippet:**
#' ```
#' control$engine_select$publish <- list(
#'   export_excel = "publish_excel_basis"
#' )
#'
#' control$params$publish <- controller_publish(
#'   params = list(
#'     export_excel = list(
#'       obj_type = "report"
#'     )
#'   )
#' )
#' ```
#'
#' **Template Reference:** `inst/templates_control/10_b_template_publish_excel.R`
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_publish()`:
#'   - `alias`: Alias of the publishing instance.
#'   - `type`: `"report"` or `"reportelement"`.
#'   - `engine`: `"publish_excel_basis"`.
#'   - `path`: Path to saved `.xlsx` file.
#'   - `success`: TRUE/FALSE indicating rendering success.
#'   - `params`: Parameter list used for publishing.
#'   - `specific_output`: Error message or `NULL`.
#'
#' @seealso 
#'   [engine_publish_excel_basis()],  
#'   [default_params_publish_excel_basis()],  
#'   [initialize_output_publish()],  
#'   [controller_publish()]
#'
#' @param control A standardized control object (see `controller_publish()`).
#' @param object A structured report or reportelement object to be published.
#' @param file_path The base path for file export (without extension).
#' @param alias_publish Unique identifier for this publishing instance.
#'
#' @return A standardized publishing output object.
#' @keywords internal
wrapper_publish_excel_basis <- function(control, object, file_path, alias_publish = NULL) {
  if (is.null(alias_publish)) stop("Publish alias must be specified.")
  
  publish_params <- control$params$publish$params[[alias_publish]]
  log_msg(sprintf("[PUBLISH] Starting Excel export for alias '%s'...", alias_publish), level = "info", control = control)
  
  # Check format compatibility
  if (!"xlsx" %in% object$compatible_formats) {
    log_msg("[PUBLISH] Excel format not supported by the given object.", level = "warn", control = control)
    return(initialize_output_publish(
      alias = alias_publish,
      type = publish_params$obj_type,
      engine = "publish_excel_basis",
      path = paste0(file_path, ".xlsx"),
      success = FALSE,
      params = publish_params,
      specific_output = list(error = "xlsx format not supported for this object.")
    ))
  } else {
    
    result <- tryCatch({
      result_path <- engine_publish_excel_basis(
        report = object,
        file_path = file_path,
        params = publish_params$params
      )
      log_msg(sprintf("[PUBLISH] Excel export completed: %s", result_path), level = "info", control = control)
      list(success = TRUE, path = result_path, specific_output = NULL)
    }, error = function(e) {
      log_msg(sprintf("[PUBLISH] Excel export failed: %s", e$message), level = "error", control = control)
      list(success = FALSE, path = paste0(file_path, ".xlsx"), specific_output = list(error = e$message))
    })
    
    initialize_output_publish(
      alias = alias_publish,
      type = publish_params$obj_type,
      engine = "publish_excel_basis",
      path = result$path,
      success = result$success,
      params = publish_params,
      specific_output = result$specific_output
    )
  }  
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Publishing Engine: Excel Export
#'
#' Provides default parameters for the `publish_excel_basis` engine.
#' This engine performs a basic export of report or reportelement content to Excel format.
#'
#' **Purpose:**
#' - Ensures framework compatibility even when no parameters are required.
#' - Allows later extension through parameterization without changing the interface.
#'
#' **Default Parameters:**
#' - *(none)* — returns an empty list.
#'
#' @seealso [wrapper_publish_excel_basis()]
#'
#' @return An empty named list of default parameters for the Excel publishing engine.
#' @keywords internal
default_params_publish_excel_basis <- function() {
  list()
}
#--------------------------------------------------------------------