#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Publishing Engine: Export Report to PDF
#'
#' Renders a complete report object as a PDF using RMarkdown.
#'
#' **Input:**
#' - `report`: A structured report object.
#' - `path`: Output path for the PDF file.
#' - `params`: Optional engine-specific parameters.
#'
#' @param report A report object created via initialize_output_report.
#' @param path File path where the PDF should be saved.
#' @param params Optional parameter list.
#'
#' @return Path to the generated PDF file.
#' @export
engine_publish_pdf_basis <- function(report, file_path, params = NULL) {
  rmd_file <- tempfile(fileext = ".Rmd")
  rmd_content <- c(
    "---",
    "output: pdf_document",
    paste0("title: \"", report$report_title, "\""),
    "---",
    ""
  )
  
  for (section in report$sections) {
    rmd_content <- c(rmd_content, paste0("## ", section$heading), "")
    for (element in section$content) {
      if (!is.list(element)) next
      if (element$type == "text" || element$type == "text_warning") {
        rmd_content <- c(rmd_content, element$content, "")
      } else if (element$type == "table") {
        rmd_content <- c(rmd_content, "```{r echo=FALSE, results='asis'}", 
                         "knitr::kable(element$content)", "```", "")
      } else if (element$type == "plot") {
        figfile <- tempfile(fileext = ".png")
        grDevices::png(figfile, width = 800, height = 600, res = 120)
        print(element$content)
        grDevices::dev.off()
        rmd_content <- c(rmd_content, paste0("![](", figfile, ")"), "")
      } else {
        rmd_content <- c(rmd_content, paste0("_Unsupported type: ", element$type, "_"), "")
      }
    }
  }
  
  writeLines(rmd_content, con = rmd_file)
  rmarkdown::render(rmd_file, output_file = file_path, quiet = TRUE)
  return(file_path)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Publishing Engine: PDF Export
#'
#' Manages inputs and metadata for PDF publishing of a report object.
#'
#' @param control Control object.
#' @param object The report or reportelement object.
#' @param file_path The base file path (without extension).
#' @param alias_publish The publishing alias.
#'
#' @return A standardized publishing output.
#' @export
wrapper_publish_pdf_basis <- function(control, object, file_path, alias_publish = NULL) {
  if (is.null(alias_publish)) stop("Publish alias must be specified.")
  
  publish_params <- control$params$publish$params[[alias_publish]]  # Accessing the evaluation parameters
  
  # Check format compatibility
  if (!"pdf" %in% object$compatible_formats) {
    return(initialize_output_publish(
      alias = alias_publish,
      type = publish_params$obj_type,
      engine = "publish_pdf_basis",
      path = paste0(file_path, ".pdf"),
      success = FALSE,
      params = publish_params,
      specific_output = list(error = "PDF format not supported for this object.")
    ))
  } else {
  
    result <- tryCatch({
      result_path <- engine_publish_pdf_basis(
        report = object,
        file_path = file_path,
        params = publish_params$params
      )
      list(success = TRUE, path = result_path, specific_output = NULL)
    }, error = function(e) {
      list(success = FALSE, path = file_path, specific_output = list(error = e$message))
    })
    
    initialize_output_publish(
      alias = alias,
      type = publish_params$obj_type,
      engine = "publish_pdf_basis",
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
#' Default Parameters for Publishing Engine: PDF Export
#'
#' @return A named list of default parameters (empty).
#' @export
default_params_publish_pdf_basis <- function() {
  list()
}
#--------------------------------------------------------------------