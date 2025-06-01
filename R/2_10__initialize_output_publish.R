#--------------------------------------------------------------------
### Output Initializer: Publishing Engine ###
#--------------------------------------------------------------------
#' Output Initializer: Publishing Engine Result
#'
#' Creates a standardized result object for publishing engines within the fairnessToolbox.
#' This initializer ensures that all publishing results are reported in a consistent structure,
#' allowing for reliable logging, debugging, and downstream tracking.
#'
#' **Purpose:**
#' - Records the result of an export or publishing process.
#' - Enables uniform evaluation and comparison of publishing outcomes across engines.
#'
#' **Standardized Output:**
#' - `alias`: User-defined alias for the published item (typically from `control$publish`).
#' - `type`: Specifies whether the published object was a `"report"` or `"reportelement"`.
#' - `engine`: Name of the publishing engine (e.g., `"engine_publish_html"`).
#' - `path`: File path to the exported file.
#' - `success`: Logical flag indicating whether the operation succeeded.
#' - `params`: Optional parameters passed to the engine.
#' - `specific_output`: Additional optional metadata, such as file size, rendering time, etc.
#'
#' **Usage Example (inside a publishing engine):**
#' ```r
#' initialize_output_publish(
#'   alias = alias_publish,
#'   type = "report",
#'   engine = "engine_publish_html",
#'   path = file_path,
#'   success = file.exists(file_path),
#'   params = control$params$publish$params[[alias_publish]]
#' )
#' ```
#'
#' @param alias Character. Alias of the report or reportelement as defined in control.
#' @param type Character. Either `"report"` or `"reportelement"`.
#' @param engine Character. Name of the publishing engine used.
#' @param path Character. Full path to the output file.
#' @param success Logical. Whether the file was successfully created.
#' @param params Optional list. Parameters that were passed to the engine.
#' @param specific_output Optional list. Additional engine-specific information or metadata.
#'
#' @return A named list containing standardized publishing metadata.
#' @export
initialize_output_publish <- function(alias, type, engine, path, success = NA, params = NULL, specific_output = NULL) {
  list(
    alias = alias,
    type = type,
    engine = engine,
    path = path,
    success = success,
    params = params,
    specific_output = specific_output
  )
}
#--------------------------------------------------------------------