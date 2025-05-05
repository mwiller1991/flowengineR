#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Reportelement Engine: Textblock – MSE Summary
#'
#' Creates a textblock summarizing the average MSE over all splits.
#'
#' **Input:**
#' - `workflow_results`: List of workflow results per split.
#'
#' @param workflow_results A named list of workflow results.
#' @return The text content (character).
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
#' Creates the full reportelement output for average MSE text.
#'
#' @param control The control object.
#' @param workflow_results A named list of workflow results.
#' @param split_output Not used.
#' @param alias A character string identifying this reportelement instance.
#'
#' @return A standardized reportelement containing the MSE summary text.
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
#' @return An empty list (no parameters required).
#' @export
default_params_reportelement_text_msesummary <- function() {
  list()
}
#--------------------------------------------------------------------