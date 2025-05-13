#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Publishing Engine: Export Report to Excel
#'
#' Writes a structured report object to an Excel file (.xlsx).
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
#' Handles export of a report object to .xlsx and metadata output.
#'
#' @param control Control object.
#' @param object The report or reportelement object.
#' @param file_path The base file path (without extension).
#' @param alias_publish The publishing alias.
#'
#' @return A standardized publishing result.
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
#' @return An empty list.
#' @export
default_params_publish_excel_basis <- function() {
  list()
}
#--------------------------------------------------------------------