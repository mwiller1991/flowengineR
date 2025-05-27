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
#' @param report A standardized report object.
#' @param file_path Output file path (without extension).
#' @param params Optional publishing parameters.
#'
#' @return Path to created Excel file.
#' @export
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
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_publish()`:
#'   - `alias`: Alias used to identify this publishing call.
#'   - `type`: Object type being published (`"report"` or `"reportelement"`).
#'   - `engine`: Engine name used (e.g., `"publish_excel_basis"`).
#'   - `path`: Full file path to the saved output.
#'   - `success`: Logical flag indicating success or failure.
#'   - `params`: Merged parameter list.
#'   - `specific_output`: Metadata (e.g., error messages if unsuccessful).
#'
#' @param control A standardized control object (see `controller_publish()`).
#' @param object A structured report or reportelement object to be published.
#' @param file_path The base path for file export (without extension).
#' @param alias_publish Unique identifier for this publishing instance.
#'
#' @return A standardized publishing output object.
#' @export
wrapper_publish_excel_basis <- function(control, object, file_path, alias_publish = NULL) {
  if (is.null(alias_publish)) stop("Publish alias must be specified.")
  
  publish_params <- control$params$publish$params[[alias_publish]]
  
  # Check format compatibility
  if (!"pdf" %in% object$compatible_formats) {
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
      list(success = TRUE, path = result_path, specific_output = NULL)
    }, error = function(e) {
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
#' @return An empty named list of default parameters for the Excel publishing engine.
#' @export
default_params_publish_excel_basis <- function() {
  list()
}
#--------------------------------------------------------------------