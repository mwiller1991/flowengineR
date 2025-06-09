#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Reportelement Engine: Textblock - MSE Summary
#'
#' Computes and formats a text summary of the average Mean Squared Error (MSE) across all splits.
#'
#' **Inputs (passed to engine via wrapper):**
#' - `workflow_results`: Named list of workflow results per split.
#'
#' **Output (returned to wrapper):**
#' - A character string summarizing the average MSE.
#'
#' @seealso [wrapper_reportelement_text_msesummary()]
#'
#' @param workflow_results A named list of workflow results.
#'
#' @return A character string containing the MSE summary.
#' @keywords internal
engine_reportelement_text_msesummary <- function(workflow_results) {
  all_mse <- sapply(workflow_results, function(result) {
    result$output_eval$eval_mse$metrics$mse
  })
  mean_mse <- mean(all_mse, na.rm = TRUE)
  sprintf("Der durchschnittliche MSE ueber alle Splits betraegt %.4f.", mean_mse)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Reportelement Engine: Textblock - MSE Summary
#'
#' Validates and prepares standardized inputs, invokes the MSE summary text engine,
#' and wraps the result using `initialize_output_reportelement()`.
#'
#' **Standardized Inputs:**
#' - `control$params$reportelement$params[[alias]]`: Named list of engine-specific parameters (not used here).
#' - `workflow_results`: Named list of workflow results per split (injected by workflow).
#' - `split_output`: Output of the splitter engine (not used by this engine).
#' - `alias`: Character string identifying the reportelement instance.
#'
#' **Engine-Specific Parameters (`control$params$reportelement$params[[alias]]`):**
#' - None. This engine works without any configuration.
#'
#' **Example Control Snippet:**
#' ```
#' control$engine_select$reportelement <- list("mse_text" = "reportelement_text_msesummary")
#' control$params$reportelement <- controller_reportelement(
#'   params = list("mse_text" = list())
#' )
#' ```
#'
#' **Template Reference:**
#' See full template in `inst/templates_control/8_a_template_reportelement_text_msesummary.R`
#'
#' **Standardized Output (returned to framework):**
#' A list structured via `initialize_output_reportelement()`:
#' - `type`: `"text"`
#' - `content`: A formatted summary sentence (character string)
#' - `compatible_formats`: `c("pdf", "html", "json", "markdown")`
#' - `input_data`: Names of used splits
#' - `params`: Empty list
#' - `specific_output`: List containing the same text under `mean_mse`
#'
#' @seealso 
#'   [engine_reportelement_text_msesummary()],  
#'   [default_params_reportelement_text_msesummary()],  
#'   [initialize_output_reportelement()],  
#'   [controller_reportelement()],  
#'   Template: `inst/templates_control/8_a_template_reportelement_text_msesummary.R`
#'
#' @param control A standardized control object (see `controller_reportelement()`).
#' @param workflow_results Named list of workflow results.
#' @param split_output Output list from the splitter engine (not used here).
#' @param alias Unique identifier for this reportelement instance.
#'
#' @return A standardized reportelement output object.
#' @keywords internal
wrapper_reportelement_text_msesummary <- function(control, workflow_results, split_output, alias = NULL) {
  text <- engine_reportelement_text_msesummary(
    workflow_results = workflow_results
  )
  
  log_msg(sprintf("[REPORTELEMENT] MSE summary generated: %s", text), level = "info", control = control)
  
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
#' - *(none)* - returns an empty list.
#'
#' @seealso [wrapper_reportelement_text_msesummary()]
#'
#' @return An empty named list of default parameters for the MSE summary text reportelement engine.
#' @keywords internal
default_params_reportelement_text_msesummary <- function() {
  list()
}
#--------------------------------------------------------------------