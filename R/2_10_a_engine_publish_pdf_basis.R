#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Publishing Engine: Export Report to PDF
#'
#' Renders a structured report object to PDF using RMarkdown.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `report`: A report object created via `initialize_output_report()`.
#' - `file_path`: File path where the PDF should be saved (with extension).
#' - `params`: Optional list of engine-specific parameters (not used in this engine).
#'
#' **Output (returned to wrapper):**
#' - A character string with the path to the successfully generated PDF file.
#'
#' @seealso [wrapper_publish_pdf_basis()]
#'
#' @param report A report object created via `initialize_output_report()`.
#' @param file_path File path where the PDF should be saved.
#' @param params Optional engine-specific parameter list.
#'
#' @return Path to the generated PDF file.
#' @keywords internal
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
#' Validates and prepares standardized inputs, checks format compatibility,
#' and invokes the PDF publishing engine. Returns standardized output using `initialize_output_publish()`.
#'
#' **Standardized Inputs:**
#' - `control$params$publish$params[[alias_publish]]`: Named list of optional engine-specific parameters.
#' - `object`: A structured report or reportelement object.
#' - `file_path`: Path (without extension) where the file should be saved.
#' - `alias_publish`: Character string identifying this publish instance.
#'
#' **Engine-Specific Parameters (`control$params$publish$params[[alias_publish]]`):**
#' - *(none)* – this engine currently accepts no additional parameters.
#'
#' **Example Control Snippet:**
#' ```
#' control$publish <- list("main_pdf" = "publish_pdf_basis")
#' control$params$publish <- controller_publish(
#'   params = list(
#'     main_pdf = list(
#'       obj_type = "report"  # or "reportelement"
#'     )
#'   )
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/10_a_template_publish_pdf.R`
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_publish()`:
#'   - `alias`: Alias of the publish instance.
#'   - `type`: `"report"` or `"reportelement"`.
#'   - `engine`: `"publish_pdf_basis"`.
#'   - `path`: Path to saved `.pdf` file.
#'   - `success`: TRUE/FALSE depending on success of rendering.
#'   - `params`: Parameter list used for publishing.
#'   - `specific_output`: List with error message if rendering failed.
#'
#' @seealso 
#'   [engine_publish_pdf_basis()],  
#'   [default_params_publish_pdf_basis()],  
#'   [initialize_output_publish()],  
#'   [controller_publish()],  
#'   Template: `inst/templates_control/10_a_template_publish_pdf.R`
#'
#' @param control A standardized control object (see `controller_publish()`).
#' @param object A structured report or reportelement object.
#' @param file_path Path (without extension) where the file should be saved.
#' @param alias_publish Unique identifier for this publishing instance.
#'
#' @return A standardized publishing output object.
#' @keywords internal
wrapper_publish_pdf_basis <- function(control, object, file_path, alias_publish = NULL) {
  if (is.null(alias_publish)) stop("Publish alias must be specified.")
  
  publish_params <- control$params$publish$params[[alias_publish]]  # Accessing the evaluation parameters
  log_msg(sprintf("[PUBLISH] Starting PDF export for alias '%s'...", alias_publish), level = "info", control = control)
  
  # Check format compatibility
  if (!"pdf" %in% object$compatible_formats) {
    log_msg("[PUBLISH] PDF format not supported by the given object.", level = "warn", control = control)
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
      log_msg(sprintf("[PUBLISH] PDF export completed: %s", result_path), level = "info", control = control)
      list(success = TRUE, path = result_path, specific_output = NULL)
    }, error = function(e) {
      log_msg(sprintf("[PUBLISH] PDF export failed: %s", e$message), level = "error", control = control)
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
#' Provides default parameters for the `publish_pdf_basis` engine.
#' This engine renders a report object to PDF using an R Markdown template.
#'
#' **Purpose:**
#' - Ensures a consistent interface even when no parameters are needed.
#' - Allows future customization of PDF rendering through parameter expansion.
#'
#' **Default Parameters:**
#' - *(none)* — returns an empty list.
#'
#' @seealso [wrapper_publish_pdf_basis()]
#'
#' @return An empty named list of default parameters for the PDF publishing engine.
#' @keywords internal
default_params_publish_pdf_basis <- function() {
  list()
}
#--------------------------------------------------------------------