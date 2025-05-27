#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Reportelement Engine: Textblock – MSE Summary
#'
#' Computes and formats a text summary of the average Mean Squared Error (MSE) across all splits.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `workflow_results`: Named list of workflow results per split.
#'
#' **Output (returned to wrapper):**
#' - A character string summarizing the average MSE.
#'
#' @param workflow_results A named list of workflow results.
#'
#' @return A character string containing the MSE summary.
#' @export
engine_reportelement_text_msesummary <- function(workflow_results) {
  all_mse <- sapply(workflow_results, function(result) {
    result$output_eval$eval_mse$metrics$mse
  })
  mean_mse <- mean(all_mse, na.rm = TRUE)
  sprintf("Der durchschnittliche MSE über alle Splits beträgt %.4f.", mean_mse)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Reportelement Engine: Textblock – MSE Summary
#'
#' Validates and prepares standardized inputs, invokes the MSE summary text engine,
#' and wraps the result using `initialize_output_reportelement()`.
#'
#' **Standardized Inputs:**
#' - `control$params$reportelement$params[[alias]]`: Named list of engine-specific parameters (not used in this engine).
#' - `workflow_results`: Named list of workflow results per split.
#' - `split_output`: Output of the splitter engine (not used by this engine).
#' - `alias`: Character string identifying the reportelement instance.
#'
#' **Standardized Output (returned to framework):**
#' - A list structured via `initialize_output_reportelement()`:
#'   - `type`: `"text"`.
#'   - `content`: Character string containing the summary.
#'   - `compatible_formats`: c("pdf", "html", "json", "markdown").
#'   - `input_data`: Names of splits used.
#'   - `params`: Empty list (no parameters required).
#'   - `specific_output`: Named list including the computed summary text.
#'
#' @param control A standardized control object (see `controller_reportelement()`).
#' @param workflow_results Named list of workflow results.
#' @param split_output Output list from the splitter engine (not used here).
#' @param alias Unique identifier for this reportelement instance.
#'
#' @return A standardized reportelement output object.
#' @export
wrapper_reportelement_text_msesummary <- function(control, workflow_results, split_output, alias = NULL) {
  text <- engine_reportelement_text_msesummary(
    workflow_results = workflow_results
  )
  
  initialize_output_reportelement(
    type = "text",
    content = text,
    compatible_formats = c("pdf", "html", "json", "markdown"),
    input_data = names(workflow_results),
    params = list(),
    specific_output = list(mean_mse = text)
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Reportelement Engine: MSE Summary
#'
#' Provides default parameters for the `reportelement_text_msesummary` engine.
#' This engine requires no configuration and uses internal aggregation logic.
#'
#' **Purpose:**
#' - Supplies a consistent interface even if no parameters are required.
#' - Ensures compatibility with the framework's parameter handling conventions.
#'
#' **Default Parameters:**
#' - *(none)* — returns an empty list.
#'
#' @return An empty named list of default parameters for the MSE summary text reportelement engine.
#' @export
default_params_reportelement_text_msesummary <- function() {
  list()
}
#--------------------------------------------------------------------