#--------------------------------------------------------------------
### Helper: Initialize Output for Publishing Engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Publishing Engines
#'
#' Creates standardized output metadata after publishing.
#'
#' **Standardized Output:**
#' - `alias`: The report or reportelement alias.
#' - `type`: Either "report" or "reportelement".
#' - `engine`: Name of the publishing engine used.
#' - `path`: The final output file path.
#' - `success`: Logical flag indicating success.
#' - `params`: Optional parameters passed to the engine.
#' - `specific_output`: Optional additional metadata (e.g. file info).
#'
#' @param alias Identifier for the published item.
#' @param type Either "report" or "reportelement".
#' @param engine Name of the publishing engine.
#' @param path File path of the exported file.
#' @param success Logical indicator whether export succeeded.
#' @param params Optional list of parameters used.
#' @param specific_output Optional method-specific results or info.
#'
#' @return A standardized list containing metadata of the publishing result.
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